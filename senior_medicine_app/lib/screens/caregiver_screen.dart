import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/health_checkin_service.dart';

class CaregiverScreen extends StatefulWidget {
  const CaregiverScreen({super.key});

  @override
  State<CaregiverScreen> createState() => _CaregiverScreenState();
}

class _CaregiverScreenState extends State<CaregiverScreen> {
  List<HealthCheckin> _weeklyCheckins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final checkins = await HealthCheckinService().getWeeklyCheckins();
      setState(() {
        _weeklyCheckins = checkins;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Caregiver Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[100],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health Status Overview
                  _buildHealthOverview(),
                  
                  const SizedBox(height: 30),
                  
                  // Weekly Health Chart
                  _buildWeeklyChart(),
                  
                  const SizedBox(height: 30),
                  
                  // Missed Reminders Section
                  _buildMissedReminders(),
                  
                  const SizedBox(height: 30),
                  
                  // Emergency Contacts
                  _buildEmergencyContacts(),
                ],
              ),
            ),
    );
  }

  Widget _buildHealthOverview() {
    final today = _weeklyCheckins.isNotEmpty ? _weeklyCheckins.first : null;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Health Status',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (today != null) ...[
              Row(
                children: [
                  Icon(
                    _getStatusIcon(today.status),
                    size: 48,
                    color: _getStatusColor(today.status),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        today.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(today.status),
                        ),
                      ),
                      Text(
                        DateFormat('MMMM dd, yyyy').format(today.date),
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              
              if (today.notes != null && today.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: double.infinity,
                  child: Text(
                    'Note: "${today.notes}"',
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ] else ...[
              const Text(
                'No health check-in today',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Health Trend',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(fontSize: 12);
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final index = value.toInt();
                          return Text(
                            index >= 0 && index < days.length ? days[index] : '',
                            style: style,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateChartSpots(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  minY: 0,
                  maxY: 2,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Good', Colors.green),
                _buildLegendItem('Neutral', Colors.orange),
                _buildLegendItem('Not Well', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  List<FlSpot> _generateChartSpots() {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < _weeklyCheckins.length && i < 7; i++) {
      final checkin = _weeklyCheckins[_weeklyCheckins.length - 1 - i];
      double y;
      switch (checkin.status) {
        case 'good':
          y = 2.0;
          break;
        case 'not well':
          y = 0.0;
          break;
        default:
          y = 1.0;
      }
      spots.add(FlSpot(i.toDouble(), y));
    }
    
    return spots;
  }

  Widget _buildMissedReminders() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reminder Status',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Mock data - replace with actual reminder tracking
            _buildReminderItem('✅ Taken: 8 AM Panadol', Colors.green),
            _buildReminderItem('❌ Missed: 2 PM Vitamin D', Colors.red),
            _buildReminderItem('✅ Taken: 9 PM Crocin', Colors.green),
            
            const SizedBox(height: 16),
            
            Text(
              'Adherence Rate: 67% (2/3)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Contacts',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.local_hospital, color: Colors.red, size: 32),
              title: const Text('Emergency Services', style: TextStyle(fontSize: 18)),
              subtitle: const Text('102'),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.green, size: 28),
                onPressed: () {
                  // TODO: Make call
                },
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue, size: 32),
              title: const Text('Family Contact', style: TextStyle(fontSize: 18)),
              subtitle: const Text('+91 98765 43210'),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.green, size: 28),
                onPressed: () {
                  // TODO: Make call
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Edit emergency contacts
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Contacts'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'good':
        return Colors.green;
      case 'not well':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'good':
        return Icons.sentiment_very_satisfied;
      case 'not well':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}