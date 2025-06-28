import 'package:flutter/material.dart';
import '../models/oxygen_data.dart';

class OxygenGauge extends StatelessWidget {
  final OxygenData data;
  
  const OxygenGauge({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerHeight = isSmallScreen ? 100.0 : 120.0;
        final titleFontSize = isSmallScreen ? 14.0 : 16.0;
        final valueFontSize = isSmallScreen ? 36.0 : 42.0;
        final unitFontSize = isSmallScreen ? 12.0 : 14.0;
        final progressScale = isSmallScreen ? 1.5 : 1.8;
        final progressOffset = isSmallScreen ? 30.0 : 40.0;
        final progressStrokeWidth = isSmallScreen ? 1.5 : 2.0;
        
        return Container(
          height: containerHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF1A1A1A),
          ),
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Oxygen Purity',
                style: TextStyle(
                  fontSize: titleFontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Transform.scale(
                        scale: progressScale,
                        child: Transform.translate(
                          offset: Offset(0, progressOffset),
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const SweepGradient(
                                startAngle: 3.14 * 1.2, // Start at 216 degrees
                                endAngle: 3.14 * 1.8,   // End at 324 degrees
                                tileMode: TileMode.decal,
                                colors: [Colors.blue, Colors.blue],
                              ).createShader(bounds);
                            },
                            child: CircularProgressIndicator(
                              value: data.flow / 100.0, // Convert percentage to 0-1
                              backgroundColor: Colors.transparent,
                              strokeWidth: progressStrokeWidth,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            data.flow.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: valueFontSize,
                              color: Colors.blue,
                              fontWeight: FontWeight.w300,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: isSmallScreen ? 6 : 8,
                              left: isSmallScreen ? 3 : 4,
                            ),
                            child: Text(
                              '%',
                              style: TextStyle(
                                fontSize: unitFontSize,
                                color: Colors.grey,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 