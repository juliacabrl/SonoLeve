import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PreferencesApp());
}

/// Paleta de cores do SonoLeve, a mesma usada na tela de ritual.
class SonoLeveColors {
  const SonoLeveColors._();

  static const Color background = Color(0xFF0F1A2B);
  static const Color surface = Color(0xFF1B283C);
  static const Color divider = Color(0xFF253247);
  static const Color switchTrackOff = Color(0xFF2A3850);
  static const Color sage = Color(0xFF8DB39C);
  static const Color textPrimary = Color(0xFFEEF1F6);
  static const Color textSecondary = Color(0xFFB4BDCA);
  static const Color textMuted = Color(0xFF8792A3);
  static const Color peach = Color(0xFFF0A57E);
  static const Color periwinkle = Color(0xFF8B97C7);
  static const Color onPeriwinkle = Color(0xFF14203A);
}

/// Aplicativo mínimo para executar a tela de preferências de forma isolada.
class PreferencesApp extends StatelessWidget {
  const PreferencesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SonoLeve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: SonoLeveColors.background,
        highlightColor: const Color(0x0AFFFFFF),
        splashColor: const Color(0x14FFFFFF),
        colorScheme: const ColorScheme.dark(
          primary: SonoLeveColors.periwinkle,
          onPrimary: SonoLeveColors.onPeriwinkle,
          secondary: SonoLeveColors.sage,
          surface: SonoLeveColors.background,
          onSurface: SonoLeveColors.textPrimary,
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: SonoLeveColors.surface,
          dialBackgroundColor: SonoLeveColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: const PreferencesScreen(),
    );
  }
}

/// Modos de aparência que a pessoa pode escolher.
enum AppearanceMode {
  automatic('Automática'),
  dark('Escura'),
  light('Clara');

  const AppearanceMode(this.label);

  final String label;
}

enum _PreferenceSection { appearance, nightSchedule }

/// Formata um horário no padrão 24 horas, como "21:00".
String _formatTime(TimeOfDay time) {
  final String hour = time.hour.toString().padLeft(2, '0');
  final String minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// Tela "Do seu jeito": preferências de aparência, horário e privacidade.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  AppearanceMode _appearance = AppearanceMode.automatic;
  TimeOfDay _nightStart = const TimeOfDay(hour: 21, minute: 0);
  TimeOfDay _nightEnd = const TimeOfDay(hour: 6, minute: 0);
  bool _reduceMotion = true;
  _PreferenceSection? _expandedSection;

  Duration get _motionDuration =>
      _reduceMotion ? Duration.zero : const Duration(milliseconds: 280);

  void _toggleSection(_PreferenceSection section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  void _selectAppearance(AppearanceMode mode) {
    setState(() {
      _appearance = mode;
      _expandedSection = null;
    });
  }

  void _toggleReduceMotion() {
    HapticFeedback.selectionClick();
    setState(() {
      _reduceMotion = !_reduceMotion;
    });
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay initialTime, String helpText) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText,
      cancelText: 'Cancelar',
      confirmText: 'Salvar',
      hourLabelText: 'Hora',
      minuteLabelText: 'Minuto',
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
  }

  Future<void> _editNightStart() async {
    final TimeOfDay? picked =
        await _pickTime(_nightStart, 'Início do horário noturno');
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _nightStart = picked;
    });
  }

  Future<void> _editNightEnd() async {
    final TimeOfDay? picked =
        await _pickTime(_nightEnd, 'Fim do horário noturno');
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _nightEnd = picked;
    });
  }

  void _goBack() {
    Navigator.maybePop(context);
  }

  void _finish() {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: SonoLeveColors.surface,
        content: Text(
          'Preferências salvas.',
          style: TextStyle(color: SonoLeveColors.textPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String nightSchedule =
        '${_formatTime(_nightStart)} — ${_formatTime(_nightEnd)}';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: SonoLeveColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _BackLink(onTap: _goBack),
                      const SizedBox(height: 24),
                      const _PreferencesHeader(),
                      const SizedBox(height: 28),
                      _ExpandableSettingRow(
                        title: 'Aparência',
                        value: _appearance.label,
                        isExpanded:
                            _expandedSection == _PreferenceSection.appearance,
                        duration: _motionDuration,
                        onTap: () =>
                            _toggleSection(_PreferenceSection.appearance),
                        child: _AppearanceOptions(
                          selected: _appearance,
                          onSelected: _selectAppearance,
                        ),
                      ),
                      const _RowDivider(),
                      _ExpandableSettingRow(
                        title: 'Seu horário noturno',
                        value: nightSchedule,
                        isExpanded: _expandedSection ==
                            _PreferenceSection.nightSchedule,
                        duration: _motionDuration,
                        onTap: () =>
                            _toggleSection(_PreferenceSection.nightSchedule),
                        child: _NightScheduleEditor(
                          start: _nightStart,
                          end: _nightEnd,
                          onEditStart: _editNightStart,
                          onEditEnd: _editNightEnd,
                        ),
                      ),
                      const _RowDivider(),
                      _SettingRow(
                        title: 'Reduzir movimento',
                        value: _reduceMotion ? 'Ativado' : 'Desativado',
                        toggled: _reduceMotion,
                        onTap: _toggleReduceMotion,
                        trailing: _SoftSwitch(
                          value: _reduceMotion,
                          duration: _motionDuration,
                        ),
                      ),
                      const _RowDivider(),
                      const _SettingRow(
                        title: 'Sons e respiração offline',
                        value: 'Disponíveis',
                        trailing: _TrailingIcon(
                          icon: Icons.wifi_off_rounded,
                          color: SonoLeveColors.sage,
                        ),
                      ),
                      const _RowDivider(),
                      const _SettingRow(
                        title: 'Seus dados ficam aqui',
                        value: 'Sem conta, microfone ou sensores',
                        trailing: _TrailingIcon(
                          icon: Icons.verified_user_outlined,
                          color: SonoLeveColors.textPrimary,
                        ),
                      ),
                      const _RowDivider(),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Spacer(),
                      const _HintCard(
                        title: 'A interface muda suavemente com o horário.',
                        message: 'À noite, sempre com pouca luz.',
                      ),
                      const SizedBox(height: 20),
                      _ConcludeButton(onPressed: _finish),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                color: SonoLeveColors.textPrimary,
              ),
              SizedBox(width: 10),
              Text(
                'Voltar',
                style: TextStyle(
                  fontSize: 15,
                  color: SonoLeveColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferencesHeader extends StatelessWidget {
  const _PreferencesHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Do seu jeito.',
          style: TextStyle(
            fontSize: 36,
            height: 1.2,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
            color: SonoLeveColors.textPrimary,
          ),
        ),
        SizedBox(height: 30),
        Text(
          'O SonoLeve acompanha o seu descanso.',
          style: TextStyle(
            fontSize: 15,
            color: SonoLeveColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: SonoLeveColors.divider,
    );
  }
}

/// Linha de preferência com título, valor atual e um elemento à direita.
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.value,
    required this.trailing,
    this.onTap,
    this.toggled,
  });

  final String title;
  final String value;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool? toggled;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        toggled: toggled,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          color: SonoLeveColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: SonoLeveColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Linha de preferência que abre um painel de opções logo abaixo dela.
class _ExpandableSettingRow extends StatelessWidget {
  const _ExpandableSettingRow({
    required this.title,
    required this.value,
    required this.isExpanded,
    required this.duration,
    required this.onTap,
    required this.child,
  });

  final String title;
  final String value;
  final bool isExpanded;
  final Duration duration;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SettingRow(
          title: title,
          value: value,
          onTap: onTap,
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: duration,
            curve: Curves.easeOutCubic,
            child: const _TrailingIcon(
              icon: Icons.keyboard_arrow_down_rounded,
              color: SonoLeveColors.textSecondary,
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: duration,
          sizeCurve: Curves.easeOutCubic,
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _TrailingIcon extends StatelessWidget {
  const _TrailingIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Icon(icon, size: 21, color: color),
    );
  }
}

/// Interruptor no estilo do layout; o toque é tratado pela linha inteira.
class _SoftSwitch extends StatelessWidget {
  const _SoftSwitch({required this.value, required this.duration});

  final bool value;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOut,
      width: 52,
      height: 30,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: value
            ? SonoLeveColors.periwinkle
            : SonoLeveColors.switchTrackOff,
        borderRadius: BorderRadius.circular(15),
      ),
      child: AnimatedAlign(
        duration: duration,
        curve: Curves.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: AnimatedContainer(
          duration: duration,
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value
                ? SonoLeveColors.onPeriwinkle
                : SonoLeveColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _AppearanceOptions extends StatelessWidget {
  const _AppearanceOptions({required this.selected, required this.onSelected});

  final AppearanceMode selected;
  final ValueChanged<AppearanceMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SonoLeveColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (final AppearanceMode mode in AppearanceMode.values)
            _ChoiceOption(
              label: mode.label,
              isSelected: mode == selected,
              onTap: () => onSelected(mode),
            ),
        ],
      ),
    );
  }
}

class _ChoiceOption extends StatelessWidget {
  const _ChoiceOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: isSelected,
      inMutuallyExclusiveGroup: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: <Widget>[
              _RadioDot(isSelected: isSelected),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: SonoLeveColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? SonoLeveColors.sage
              : SonoLeveColors.textSecondary,
          width: 1.6,
        ),
      ),
      child: isSelected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: SonoLeveColors.sage,
              ),
            )
          : null,
    );
  }
}

class _NightScheduleEditor extends StatelessWidget {
  const _NightScheduleEditor({
    required this.start,
    required this.end,
    required this.onEditStart,
    required this.onEditEnd,
  });

  final TimeOfDay start;
  final TimeOfDay end;
  final VoidCallback onEditStart;
  final VoidCallback onEditEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _TimeTile(label: 'Início', time: start, onTap: onEditStart),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TimeTile(label: 'Fim', time: end, onTap: onEditEnd),
        ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SonoLeveColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: SonoLeveColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(time),
                style: const TextStyle(
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w300,
                  color: SonoLeveColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: SonoLeveColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            width: 26,
            child: Icon(
              Icons.auto_awesome_outlined,
              size: 22,
              color: SonoLeveColors.peach,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: SonoLeveColors.peach,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: SonoLeveColors.textSecondary,
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

class _ConcludeButton extends StatelessWidget {
  const _ConcludeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: SonoLeveColors.periwinkle,
          foregroundColor: SonoLeveColors.onPeriwinkle,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Concluir'),
      ),
    );
  }
}
