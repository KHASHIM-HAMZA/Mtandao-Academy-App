import 'package:flutter/material.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);
  String? selectedPlan;
  String? selectedPaymentMethod;
  bool _isProcessing = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final List<Map<String, dynamic>> plans = [
    {
      'title': 'Weekly Plan',
      'price': 'Tsh 20,000',
      'originalPrice': 'Tsh 25,000',
      'period': '7 days',
      'description': 'Perfect for short-term learning goals',
      'color': Colors.orange.shade600,
      'popular': false,
      'savings': 'Save 20%',
    },
    {
      'title': 'Monthly Plan',
      'price': 'Tsh 50,000',
      'originalPrice': 'Tsh 60,000',
      'period': '30 days',
      'description': 'Best value for continuous learning',
      'color': Colors.green.shade600,
      'popular': true,
      'savings': 'Save 17%',
    },
    {
      'title': 'Yearly Plan',
      'price': 'Tsh 500,000',
      'originalPrice': 'Tsh 600,000',
      'period': '365 days',
      'description': 'Complete academic year access',
      'color': Colors.blue.shade700,
      'popular': false,
      'savings': 'Save 17%',
    },
  ];

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'name': 'M-Pesa',
      'logo': 'assets/mpesa.png',
      'color': Colors.green.shade700,
    },
    {
      'name': 'Tigo Pesa',
      'logo': 'assets/tigopesa.png',
      'color': Colors.purple.shade700,
    },
    {
      'name': 'Airtel Money',
      'logo': 'assets/airtelmoney.png',
      'color': Colors.red.shade600,
    },
    {
      'name': 'Halo Pesa',
      'logo': 'assets/halopesa.png',
      'color': Colors.blue.shade800,
    },
    {'name': 'CRDB', 'logo': 'assets/crdb.png', 'color': Colors.blue.shade900},
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a subscription plan'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a payment method'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isProcessing = false);
      _showPaymentSuccessDialog();
    });
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You have successfully subscribed to the $selectedPlan',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to home page
                },
                child: const Text('Continue Learning'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 180,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Decorative elements
                        Positioned(
                          top: 30,
                          right: 30,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          left: 20,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Center(
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Transform.translate(
                              offset: Offset(0, _slideAnimation.value * 0.5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.workspace_premium,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Upgrade Your Learning',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Unlock all features with premium',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Plans Section
                          const Text(
                            'Choose Your Plan',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Select the plan that works best for you',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Plans List
                          ...plans.map((plan) => _buildPlanCard(plan)).toList(),

                          const SizedBox(height: 30),

                          // Payment Methods Section
                          const Text(
                            'Select Payment Method',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Choose your mobile money provider',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Payment Methods Grid
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 0.9,
                                ),
                            itemCount: paymentMethods.length,
                            itemBuilder: (context, index) {
                              final method = paymentMethods[index];
                              return _buildPaymentMethodCard(method);
                            },
                          ),

                          const SizedBox(height: 30),

                          // Proceed Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(
                                      _isProcessing ? 0.4 : 0.3,
                                    ),
                                    blurRadius: _isProcessing ? 15 : 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed:
                                    _isProcessing ? null : _proceedToPayment,
                                child:
                                    _isProcessing
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                        : const Text(
                                          'Proceed to Payment',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Features List
                          _buildFeaturesList(),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    bool isSelected = selectedPlan == plan['title'];
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? plan['color'] as Color : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: plan['color'] as Color,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.star, color: Colors.white, size: 24),
        ),
        title: Row(
          children: [
            Text(
              plan['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (plan['popular'] as bool) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(plan['description'] as String),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  plan['price'] as String,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: plan['color'] as Color,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  plan['period'] as String,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  plan['originalPrice'] as String,
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  plan['savings'] as String,
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Radio<String>(
          value: plan['title'] as String,
          groupValue: selectedPlan,
          onChanged: (value) {
            setState(() {
              selectedPlan = value;
            });
          },
          activeColor: plan['color'] as Color,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    bool isSelected = selectedPaymentMethod == method['name'];
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method['name'] as String;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? method['color'].withOpacity(0.1) as Color
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? method['color'] as Color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: method['color'] as Color,
              ),
              child: Image.asset(
                method['logo'] as String,
                errorBuilder:
                    (context, error, stackTrace) =>
                        Icon(Icons.payment, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              method['name'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? method['color'] as Color : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What You Get:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          ...[
                'Access to all subjects and levels',
                'Unlimited video tutorials',
                'Downloadable notes and books',
                'Practice tests and mock exams',
                'Progress tracking and analytics',
                'Priority teacher support',
                'Offline content access',
                'No advertisements',
              ]
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(feature, style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
