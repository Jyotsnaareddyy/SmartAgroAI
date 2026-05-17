import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../widgets/sensor_card.dart';
import 'ai_assistant_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeviceProvider>(context, listen: false).loadDevices('z1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);
    final mockPumpId = 'd_z1_r1';
    final isPumpOn = deviceProvider.isPumpOn(mockPumpId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartAgro AI Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.settings_outlined), 
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            }
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
          );
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Ask AI'),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
      ),
      body: deviceProvider.isLoading && deviceProvider.latestData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 80.0), // Padding for FAB
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enterprise Weather Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Green Valley Farm - Alpha Sector', 
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.thermostat, size: 20, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text('25°C', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 16),
                                const Icon(Icons.water_drop, size: 20, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text('10%', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Cloudy • Chance of rain', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cloud, size: 40, color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // NEW AI SECTION
                  _buildAIAssistantSection(context),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Live Telemetry', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      if (deviceProvider.isLoading)
                         const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (deviceProvider.latestData != null)
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      childAspectRatio: 1.1,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        SensorCard(
                          title: 'Soil Moisture', 
                          value: '${deviceProvider.latestData!.soilMoisture?.toStringAsFixed(1)}%', 
                          icon: Icons.grass, 
                          color: const Color(0xFF2E7D32),
                        ),
                        SensorCard(
                          title: 'Temperature', 
                          value: '${deviceProvider.latestData!.temperature?.toStringAsFixed(1)}°C', 
                          icon: Icons.thermostat, 
                          color: const Color(0xFFEF6C00),
                        ),
                        SensorCard(
                          title: 'Humidity', 
                          value: '${deviceProvider.latestData!.humidity?.toStringAsFixed(1)}%', 
                          icon: Icons.air, 
                          color: const Color(0xFF00838F),
                        ),
                        SensorCard(
                          title: 'Battery', 
                          value: '${deviceProvider.latestData!.batteryLevel?.toStringAsFixed(0)}%', 
                          icon: Icons.battery_charging_full, 
                          color: const Color(0xFF1565C0),
                        ),
                      ],
                    )
                  else
                    const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No telemetry available.'))),
                  
                  const SizedBox(height: 32),
                  Text('Device Controls', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isPumpOn ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPumpOn ? Theme.of(context).colorScheme.primary.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
                        width: isPumpOn ? 2 : 1,
                      )
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isPumpOn ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.power_settings_new,
                          color: isPumpOn ? Colors.white : Colors.grey,
                          size: 28,
                        ),
                      ),
                      title: Text('Main Water Pump', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text(isPumpOn ? 'Status: ACTIVE' : 'Status: IDLE', style: TextStyle(color: isPumpOn ? Theme.of(context).colorScheme.primary : Colors.grey)),
                      trailing: Switch(
                        value: isPumpOn,
                        onChanged: (val) => deviceProvider.togglePump(mockPumpId, val),
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAIAssistantSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.15),
            Colors.orange.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text('SmartAgro AI Assistant', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange[800])),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Recommendation: Delay irrigation for Alpha Sector. Soil moisture is adequate and there is a 60% chance of rain tomorrow.',
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Ask AI for advice...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
