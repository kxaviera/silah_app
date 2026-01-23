import 'package:flutter/material.dart';

import '../screens/ad_detail_screen.dart';
import '../screens/discover_screen.dart' show ProfileAd;

class ProfileAdCard extends StatelessWidget {
  final ProfileAd ad;
  const ProfileAdCard({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: ad.featured || ad.sponsored
              ? theme.colorScheme.primary.withOpacity(0.3)
              : Colors.grey.shade200,
          width: ad.featured || ad.sponsored ? 2 : 1,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdDetailScreen(userId: ad.id, ad: ad),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        ad.name[0],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  if (ad.featured || ad.sponsored)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: ad.featured
                              ? theme.colorScheme.primary
                              : Colors.orange.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          ad.featured ? Icons.star : Icons.workspace_premium,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  ad.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (ad.isVerified)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Icon(
                                    Icons.verified,
                                    size: 18,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (ad.featured)
                          _badge('Featured', theme.colorScheme.primary),
                        if (ad.sponsored)
                          _badge('Sponsored', Colors.orange.shade600),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _infoChip(Icons.cake_outlined, '${ad.age} years'),
                        _infoChip(Icons.flag_outlined, ad.country),
                        if (ad.livingCountry != null &&
                            ad.livingCountry!.isNotEmpty &&
                            ad.livingCountry != ad.country)
                          _infoChip(Icons.flight_takeoff_outlined,
                              'Living in ${ad.livingCountry}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _infoChip(Icons.church_outlined, ad.religion),
                        if (ad.height != null)
                          _infoChip(Icons.height_outlined, '${ad.height} cm'),
                        if (ad.profession != null)
                          _infoChip(Icons.work_outline, ad.profession!),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'View full profile',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black54),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
