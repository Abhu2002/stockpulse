import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/stock_bloc.dart';
import '../widgets/app_logo.dart';
import '../widgets/stock_cards.dart';
import 'profile_screen.dart';

class StockDashboardScreen extends StatefulWidget {
  const StockDashboardScreen({super.key});

  static const routeName = '/stocks';

  @override
  State<StockDashboardScreen> createState() => _StockDashboardScreenState();
}

class _StockDashboardScreenState extends State<StockDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StockBloc>().add(const StocksRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(compact: true),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () =>
                Navigator.of(context).pushNamed(ProfileScreen.routeName),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          if (state.status == StockStatus.loading ||
              state.status == StockStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == StockStatus.failure) {
            final isNetworkError =
                state.errorMessage?.toLowerCase().contains(
                  'network unavailable',
                ) ==
                true;
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNetworkError ? Icons.wifi_off : Icons.error_outline,
                      size: 72,
                      color: const Color(0xFF334E68),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isNetworkError
                          ? 'Network unavailable'
                          : 'Unable to load market data',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF102A43),
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.errorMessage ??
                          'Please try again when your connection is restored.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => context.read<StockBloc>().add(
                        const StocksRequested(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state.stocks.isEmpty && state.indices.isEmpty) {
            return const Center(child: Text('No market data found.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<StockBloc>().add(const StocksRequested());
              await Future<void>.delayed(const Duration(milliseconds: 600));
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _MarketHeader(liveConnected: state.liveConnected),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 218,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) =>
                          IndexCard(index: state.indices[index]),
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemCount: state.indices.length,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Top stocks',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF102A43),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.crossAxisExtent > 720;
                      if (!wide) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            if (index.isOdd) {
                              return const SizedBox(height: 12);
                            }

                            final stockIndex = index ~/ 2;
                            return StockTile(stock: state.stocks[stockIndex]);
                          }, childCount: state.stocks.length * 2 - 1),
                        );
                      }

                      return SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 190,
                        ),
                        itemBuilder: (context, index) =>
                            StockTile(stock: state.stocks[index]),
                        itemCount: state.stocks.length,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MarketHeader extends StatelessWidget {
  const _MarketHeader({required this.liveConnected});

  final bool liveConnected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF102A43),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Live index stream with assignment stock data.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFD9E2EC),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: liveConnected
                  ? const Color(0xFF0F766E)
                  : const Color(0xFFC2410C),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sensors, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  liveConnected ? 'Live' : 'Offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
