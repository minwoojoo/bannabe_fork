import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/rental_viewmodel.dart';
import '../../../data/models/accessory.dart';
import '../../../core/widgets/bottom_navigation_bar.dart';
import '../../../app/routes.dart';
import './rental_detail_view.dart';
import '../../../core/widgets/loading_animation.dart';
import '../../../core/constants/app_colors.dart';

class RentalView extends StatelessWidget {
  const RentalView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RentalViewModel(),
      child: const _RentalContent(),
    );
  }
}

class _RentalContent extends StatelessWidget {
  const _RentalContent();

  String _getCategoryName(AccessoryCategory category) {
    switch (category) {
      case AccessoryCategory.charger:
        return '충전기';
      case AccessoryCategory.powerBank:
        return '보조배터리';
      case AccessoryCategory.dock:
        return '독';
      case AccessoryCategory.cable:
        return '케이블';
      default:
        return '기타';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('대여하기'),
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(Routes.home);
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            body: SafeArea(
              child: Consumer<RentalViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(
                      child: HoneyLoadingAnimation(
                        isStationSelected: false,
                      ),
                    );
                  }

                  if (viewModel.error != null) {
                    return Center(child: Text(viewModel.error!));
                  }

                  return DefaultTextStyle.merge(
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    child: RefreshIndicator(
                      onRefresh: viewModel.refresh,
                      child: CustomScrollView(
                        slivers: [
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 16),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '대여 가능한 물품',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.search,
                                          color: Colors.grey[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            onChanged:
                                                viewModel.searchAccessories,
                                            decoration: const InputDecoration(
                                              hintText: '악세사리 검색',
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 40,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: AccessoryCategory.values
                                          .map(
                                            (category) => Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: viewModel
                                                              .selectedCategory ==
                                                          category.toString()
                                                      ? AppColors.primary
                                                      : Colors.grey[200],
                                                  foregroundColor: viewModel
                                                              .selectedCategory ==
                                                          category.toString()
                                                      ? Colors.white
                                                      : Colors.black,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    viewModel.selectCategory(
                                                        category.toString()),
                                                child: Text(
                                                  _getCategoryName(category),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final accessory =
                                    viewModel.filteredAccessories[index];
                                return InkWell(
                                  onTap: () {
                                    viewModel.selectAccessory(accessory);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => RentalDetailView(
                                          accessory: accessory,
                                          station: viewModel.selectedStation,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                accessory.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                accessory.description,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${accessory.pricePerHour}원/시간',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: viewModel.filteredAccessories.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const AppBottomNavigationBar(currentIndex: 1),
      ],
    );
  }
}
