import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Paleta de cores da tela de ritual, extraída do layout de referência.

class RitualColors {
  const RitualColors._();
  static const Color background = Color(0xFF0F1A2B);
  static const Color surface = Color(0xFF1B283C);
  static const Color divider = Color(0xFF1F2C40);
  static const Color progressTrack = Color(0xFF2A3850);
  static const Color sage = Color(0xFF8DB39C);
  static const Color textPrimary = Color(0xFFEEF1F6);
  static const Color textSecondary = Color(0xFFB4BDCA);
  static const Color textDone = Color(0xFF8A9A97);
  static const Color textMuted = Color(0xFF8792A3);
  static const Color peach = Color(0xFFF0A57E);
  static const Color periwinkle = Color(0xFF8B97C7);
  static const Color onPeriwinkle = Color(0xFF14203A);
}

// Aplicativo mínimo para executar a tela de ritual de forma isolada.

class RitualApp extends StatelessWidget {
  const RitualApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seu ritual',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: RitualColors.background,
        highlightColor: const Color(0x0AFFFFFF),
        splashColor: const Color(0x14FFFFFF),
        colorScheme: const ColorScheme.dark(
          primary: RitualColors.periwinkle,
          onPrimary: RitualColors.onPeriwinkle,
          secondary: RitualColors.sage,
          surface: RitualColors.background,
          onSurface: RitualColors.textPrimary,
        ),
      ),
      home: const RitualScreen(),
    );
  }
}

// Passo do ritual noturno e seu estado de conclusão.

class RitualStep {
  const RitualStep({required this.title, this.isDone = false});
  final String title;
  final bool isDone;
  RitualStep copyWith({bool? isDone}) {
    return RitualStep(title: title, isDone: isDone ?? this.isDone);
  }
}

// Tela "Seu ritual, no seu tempo": checklist de cuidados antes de dormir.

class RitualScreen extends StatefulWidget {
  const RitualScreen({super.key});

  @override
  State<RitualScreen> createState() => _RitualScreenState();
}

class _RitualScreenState extends State<RitualScreen> {
  final List<RitualStep> _steps = <RitualStep>[
    const RitualStep(title: 'Reduzir a luz do ambiente', isDone: true),
    const RitualStep(title: 'Silenciar as notificações', isDone: true),
    const RitualStep(title: 'Preparar um lugar tranquilo'),
    const RitualStep(title: 'Reservar um tempo para mim'),
  ];
  int _selectedTabIndex = 0;
  int get _doneCount => _steps.where((RitualStep step) => step.isDone).length;
  void _toggleStep(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _steps[index] = _steps[index].copyWith(isDone: !_steps[index].isDone);
    });
  }
  void _selectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }
  void _goBack() {
    Navigator.maybePop(context);
  }
  void _startRelaxing() {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: RitualColors.surface,
        content: Text(
          'Hora de relaxar. Boa noite.',
          style: TextStyle(color: RitualColors.textPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: RitualColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _BackLink(onTap: _goBack),
                const SizedBox(height: 24),
                const _RitualHeader(),
                const SizedBox(height: 10),
                _ProgressSummary(done: _doneCount, total: _steps.length),
                const SizedBox(height: 24),
                for (int i = 0; i < _steps.length; i++) ...<Widget>[
                  _RitualStepTile(
                    step: _steps[i],
                    onTap: () => _toggleStep(i),
                  ),
                  if (i < _steps.length - 1) const SizedBox(height: 13),
                ],
                const SizedBox(height: 34),
                const _EncouragementCard(),
                const SizedBox(height: 22),
                _RelaxButton(onPressed: _startRelaxing),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _RitualBottomNav(
          selectedIndex: _selectedTabIndex,
          onSelected: _selectTab,
        ),
      ),
    );
  }
}

class _BackLink extends StatelessWidget {
  const _BackLink({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: RitualColors.textPrimary,
              ),
              SizedBox(width: 10),
              Text(
                'Voltar',
                style: TextStyle(
                  fontSize: 15,
                  color: RitualColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RitualHeader extends StatelessWidget {
  const _RitualHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Seu ritual,\nno seu tempo.',
          style: TextStyle(
            fontSize: 36,
            height: 1.2,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
            color: RitualColors.textPrimary,
          ),
        ),
        SizedBox(height: 30),
        Text(
          'Pequenos cuidados para encerrar o dia.',
          style: TextStyle(
            fontSize: 15,
            color: RitualColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// Contador "x de y" com barra de progresso animada.

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.done, required this.total});
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final double fraction = total == 0 ? 0 : done / total;
    const TextStyle labelStyle = TextStyle(
      fontSize: 13,
      color: RitualColors.textSecondary,
    );
    return Semantics(
      label: '$done de $total cuidados concluídos',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(child: Text('Hoje, sem pressa', style: labelStyle)),
              Text('$done de $total', style: labelStyle),
            ],
          ),
          const SizedBox(height: 9),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: fraction),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (BuildContext context, double value, Widget? child) {
              return Container(
                height: 3,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: RitualColors.progressTrack,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  widthFactor: value,
                  heightFactor: 1,
                  child: child,
                ),
              );
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: RitualColors.sage,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RitualStepTile extends StatelessWidget {
  const _RitualStepTile({required this.step, required this.onTap});
  final RitualStep step;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = DefaultTextStyle.of(context).style.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: step.isDone ? RitualColors.textDone : RitualColors.textPrimary,
        );
    return Semantics(
      button: true,
      checked: step.isDone,
      child: Material(
        color: RitualColors.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: <Widget>[
                _StepCheckmark(isDone: step.isDone),
                const SizedBox(width: 14),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: titleStyle,
                    child: Text(step.title),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepCheckmark extends StatelessWidget {
  const _StepCheckmark({required this.isDone});
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? RitualColors.sage : Colors.transparent,
        border: Border.all(
          color: isDone ? RitualColors.sage : RitualColors.textPrimary,
          width: 1.6,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: isDone
            ? const Icon(
                Icons.check_rounded,
                key: ValueKey<bool>(true),
                size: 17,
                color: RitualColors.background,
              )
            : const SizedBox.shrink(key: ValueKey<bool>(false)),
      ),
    );
  }
}

class _EncouragementCard extends StatelessWidget {
  const _EncouragementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: RitualColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 26,
            child: Icon(
              Icons.auto_awesome_outlined,
              size: 22,
              color: RitualColors.peach,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Um pequeno cuidado já é um começo.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: RitualColors.peach,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Não precisa fazer tudo hoje.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: RitualColors.textSecondary,
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

class _RelaxButton extends StatelessWidget {
  const _RelaxButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: RitualColors.periwinkle,
          foregroundColor: RitualColors.onPeriwinkle,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Agora, relaxar'),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _RitualBottomNav extends StatelessWidget {
  const _RitualBottomNav({
    required this.selectedIndex,
    required this.onSelected,
  });
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  static const List<_NavDestination> _destinations = <_NavDestination>[
    _NavDestination(icon: Icons.bedtime_outlined, label: 'Hoje'),
    _NavDestination(icon: Icons.graphic_eq_rounded, label: 'Sons'),
    _NavDestination(icon: Icons.menu_book_outlined, label: 'Diário'),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RitualColors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Divider(
                height: 1,
                thickness: 1,
                color: RitualColors.divider,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: <Widget>[
                    for (int i = 0; i < _destinations.length; i++)
                      Expanded(
                        child: _NavItem(
                          destination: _destinations[i],
                          isSelected: i == selectedIndex,
                          onTap: () => onSelected(i),
                        ),
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
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });
  final _NavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        isSelected ? RitualColors.textPrimary : RitualColors.textMuted;
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(destination.icon, size: 24, color: color),
              const SizedBox(height: 6),
              Text(
                destination.label,
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
