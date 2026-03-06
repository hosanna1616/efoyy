import 'package:flutter/material.dart';

class QueueOrbWidget extends StatefulWidget {
  final int position;
  final int total;
  final int queueNumber;

  const QueueOrbWidget({
    super.key,
    required this.position,
    required this.total,
    required this.queueNumber,
  });

  @override
  State<QueueOrbWidget> createState() => _QueueOrbWidgetState();
}

class _QueueOrbWidgetState extends State<QueueOrbWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.total > 0 ? (widget.position + 1) / widget.total : 0.0;
    final estimatedMinutes = (widget.position + 1) * 10;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.blue.withOpacity(0.8 * _pulseAnimation.value),
                Colors.green.withOpacity(0.6 * _pulseAnimation.value),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5 * _pulseAnimation.value),
                blurRadius: 30 * _pulseAnimation.value,
                spreadRadius: 10 * _pulseAnimation.value,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: 1 - progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.position == 0 ? Colors.green : Colors.blue,
                  ),
                ),
              ),
              // Center content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.position + 1}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '/ ${widget.total}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '~$estimatedMinutes min',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}


