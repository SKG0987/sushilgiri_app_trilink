import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final int selectedTabIndex;

  const MapScreen({super.key, required this.selectedTabIndex});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng _currentPosition = const LatLng(27.7172, 85.3240);
  LatLng? _searchPosition;
  double _currentRotation = 0;
  static const LatLng _pinnedLocation = LatLng(28.123318, 84.101257);
  bool _isLoadingLocation = false;
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_pinnedLocation, 14);
    });
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTabIndex == 1 && oldWidget.selectedTabIndex != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_pinnedLocation, 14);
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentPosition, 15);
    } catch (_) {}
    if (!mounted) return;
    setState(() => _isLoadingLocation = false);
  }

  void _goToCurrentLocation() {
    if (_currentPosition.latitude != 27.7172 ||
        _currentPosition.longitude != 85.3240) {
      _mapController.move(_currentPosition, 15);
    } else {
      _getCurrentLocation();
    }
  }

  void _resetNorth() {
    _mapController.rotate(0);
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final encoded = Uri.encodeQueryComponent(query);
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=$encoded&format=json&limit=5'),
        headers: {'User-Agent': 'trilink_assignment/1.0'},
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _searchResults = json.decode(response.body);
          _showSearchResults = true;
        });
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() => _isSearching = false);
  }

  void _goToSearchResult(dynamic result) {
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);
    _searchPosition = LatLng(lat, lon);
    _mapController.move(_searchPosition!, 12);
    setState(() {
      _showSearchResults = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pinnedLocation,
              initialZoom: 14,
              onMapEvent: (event) {
                setState(
                    () => _currentRotation = event.camera.rotation);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.intern_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 100,
                    height: 60,
                    point: _pinnedLocation,
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.push_pin,
                          color: Color(0xFFDC2626),
                          size: 36,
                        ),
                        const SizedBox(height: 2),
                        DecoratedBox(
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            borderRadius:
                                BorderRadius.all(Radius.circular(4)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            child: Text(
                              'Sushil Giri',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_currentPosition.latitude != 27.7172 ||
                      _currentPosition.longitude != 85.3240)
                    Marker(
                      point: _currentPosition,
                      child: const Icon(
                        Icons.gps_fixed,
                        color: Color(0xFF4F46E5),
                        size: 32,
                      ),
                    ),
                  if (_searchPosition != null)
                    Marker(
                      point: _searchPosition!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),
          // Search bar
          Positioned(
            top: topPadding + 10,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search places...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                            )
                          : _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchResults = [];
                                      _showSearchResults = false;
                                    });
                                  },
                                )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    onChanged: _searchLocation,
                  ),
                ),
                if (_showSearchResults && _searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        final displayName =
                            result['display_name'] as String? ?? '';
                        final type = result['type'] as String? ?? '';
                        final category =
                            result['category'] as String? ?? '';
                        final parts = displayName.split(',');
                        final name = parts.isNotEmpty ? parts[0] : '';
                        final rest = parts.length > 1
                            ? parts.sublist(1).join(',').trim()
                            : '';

                        return ListTile(
                          dense: true,
                          leading: Icon(
                            type == 'city' || type == 'town' ||
                                    type == 'village' ||
                                    type == 'administrative'
                                ? Icons.location_city
                                : Icons.place,
                            color: const Color(0xFF4F46E5),
                          ),
                          title: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: rest.isNotEmpty
                              ? Text(
                                  rest,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey),
                                )
                              : null,
                          onTap: () => _goToSearchResult(result),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          // Location & Compass buttons
          Positioned(
            bottom: 40,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFloatingButton(
                  onTap: _resetNorth,
                  child: Transform.rotate(
                    angle: _currentRotation * 3.1415927 / 180,
                    child: const Icon(Icons.navigation,
                        color: Color(0xFF4F46E5)),
                  ),
                ),
                const SizedBox(height: 12),
                _buildFloatingButton(
                  onTap: _goToCurrentLocation,
                  child: _isLoadingLocation
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF4F46E5),
                          ),
                        )
                      : const Icon(Icons.my_location,
                          color: Color(0xFF4F46E5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}
