import 'package:flutter/material.dart';

const Map<String, IconData> kCategoryIcons = {
  // Finance & Money
  'wallet': Icons.account_balance_wallet_outlined,
  'bank': Icons.account_balance_outlined,
  'cash': Icons.payments_outlined,
  'credit_card': Icons.credit_card_outlined,
  'savings': Icons.savings_outlined,
  'money': Icons.attach_money,
  'currency': Icons.currency_exchange,
  'salary': Icons.work_outline,
  'business': Icons.business_center_outlined,
  'interest': Icons.percent,
  'stocks': Icons.show_chart,
  'trending_up': Icons.trending_up,
  'trending_down': Icons.trending_down,
  'crypto': Icons.currency_bitcoin,
  'gold': Icons.workspace_premium_outlined,
  'mutual_fund': Icons.pie_chart_outline,
  'investment': Icons.bar_chart,
  'loan': Icons.account_balance,
  'insurance': Icons.shield_outlined,
  'tax': Icons.receipt_long_outlined,
  'donation': Icons.volunteer_activism_outlined,
  'gift': Icons.card_giftcard_outlined,

  // Food & Drink
  'food': Icons.restaurant_outlined,
  'restaurant': Icons.dining_outlined,
  'coffee': Icons.coffee_outlined,
  'fastfood': Icons.fastfood_outlined,
  'grocery': Icons.local_grocery_store_outlined,
  'bakery': Icons.bakery_dining_outlined,
  'bar': Icons.local_bar_outlined,
  'cake': Icons.cake_outlined,
  'icecream': Icons.icecream_outlined,

  // Transport
  'transport': Icons.directions_bus_outlined,
  'car': Icons.directions_car_outlined,
  'taxi': Icons.local_taxi_outlined,
  'bike': Icons.pedal_bike_outlined,
  'motorcycle': Icons.two_wheeler_outlined,
  'flight': Icons.flight_outlined,
  'train': Icons.train_outlined,
  'fuel': Icons.local_gas_station_outlined,
  'parking': Icons.local_parking,

  // Shopping
  'shopping': Icons.shopping_bag_outlined,
  'shopping_cart': Icons.shopping_cart_outlined,
  'store': Icons.store_outlined,
  'clothes': Icons.checkroom_outlined,
  'shoe': Icons.backpack_outlined,

  // Home & Utilities
  'utilities': Icons.bolt_outlined,
  'home': Icons.home_outlined,
  'rent': Icons.house_outlined,
  'water': Icons.water_drop_outlined,
  'electric': Icons.electrical_services_outlined,
  'internet': Icons.wifi_outlined,
  'phone_bill': Icons.phone_outlined,
  'furniture': Icons.chair_outlined,
  'tools': Icons.handyman_outlined,
  'cleaning': Icons.cleaning_services_outlined,

  // Health
  'healthcare': Icons.local_hospital_outlined,
  'medicine': Icons.medication_outlined,
  'fitness': Icons.fitness_center_outlined,
  'spa': Icons.spa_outlined,
  'dental': Icons.medical_services_outlined,

  // Education
  'education': Icons.school_outlined,
  'book': Icons.menu_book_outlined,
  'study': Icons.auto_stories_outlined,
  'laptop': Icons.laptop_outlined,

  // Entertainment
  'entertainment': Icons.movie_outlined,
  'music': Icons.music_note_outlined,
  'games': Icons.sports_esports_outlined,
  'sports': Icons.sports_soccer_outlined,
  'travel': Icons.travel_explore_outlined,
  'hotel': Icons.hotel_outlined,
  'camera': Icons.photo_camera_outlined,
  'tv': Icons.tv_outlined,
  'streaming': Icons.live_tv_outlined,

  // Personal
  'beauty': Icons.face_outlined,
  'haircut': Icons.content_cut_outlined,
  'pet': Icons.pets_outlined,
  'child': Icons.child_care_outlined,
  'baby': Icons.baby_changing_station_outlined,

  // General
  'category': Icons.category_outlined,
  'star': Icons.star_outline,
  'heart': Icons.favorite_outline,
  'flag': Icons.flag_outlined,
  'pin': Icons.push_pin_outlined,
  'tag': Icons.label_outline,
  'other': Icons.more_horiz,
};

IconData iconFromName(String name) =>
    kCategoryIcons[name] ?? Icons.category_outlined;
