import 'package:e7gezly/core/constants/colors.dart';
import 'package:e7gezly/presentation/widgets/playstation_booking_logic.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../domain/usecases/fetch_playstation_details_usecase.dart';

class BookingDialog extends StatelessWidget {
  final String roomId;
  final String roomName;
  final bool ps4Available;
  final bool ps5Available;
  final DateTime selectedDate;
  final String playStationId;
  final BookingUseCase useCase;

  const BookingDialog({
    required this.roomId,
    required this.roomName,
    required this.ps4Available,
    required this.ps5Available,
    required this.selectedDate,
    required this.playStationId,
    required this.useCase,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.prColor,
      title: Text(tr('booking_room')).tr(),
      content: _BookingDialogContent(
        roomId: roomId,
        roomName: roomName,
        ps4Available: ps4Available,
        ps5Available: ps5Available,
        selectedDate: selectedDate,
        playStationId: playStationId,
        useCase: useCase,
      ),
    );
  }
}

class _BookingDialogContent extends StatefulWidget {
  final String roomId;
  final String roomName;
  final bool ps4Available;
  final bool ps5Available;
  final DateTime selectedDate;
  final String playStationId;
  final BookingUseCase useCase;

  const _BookingDialogContent({
    required this.roomId,
    required this.roomName,
    required this.ps4Available,
    required this.ps5Available,
    required this.selectedDate,
    required this.playStationId,
    required this.useCase,
  });

  @override
  __BookingDialogContentState createState() => __BookingDialogContentState();
}

class __BookingDialogContentState extends State<_BookingDialogContent> {
  TimeOfDay? selectedTime;
  String selectedMode = 'فردي';
  String selectedConsole = 'PS4';
  double hourlyRate = 0.0;
  bool isTimeAvailable = true;
  bool _isLoading = false;

  late final BookingHelper _bookingHelper;

  @override
  void initState() {
    super.initState();
    _bookingHelper = BookingHelper(useCase: widget.useCase);
    selectedConsole = widget.ps4Available ? 'PS4' : 'PS5';
    _updateHourlyRate();
  }

  Future<void> _updateHourlyRate() async {
    await _bookingHelper.updateHourlyRate(
      playStationId: widget.playStationId,
      roomId: widget.roomId,
      console: selectedConsole,
      mode: selectedMode,
      onRateUpdated: (rate) {
        setState(() {
          hourlyRate = rate;
        });
      },
    );
  }

  Future<void> _selectTime() async {
    bool isAvailable = await _bookingHelper.selectTime(
      context: context,
      selectedDate: widget.selectedDate,
      playStationId: widget.playStationId, // Pass playStationId
      roomId: widget.roomId, // Pass roomId
      onTimeSelected: (time) {
        setState(() {
          selectedTime = time;
        });
      },
    );

    if (isAvailable) {
      setState(() {
        isTimeAvailable = true;
      });
    } else {
      setState(() {
        isTimeAvailable = false;
      });
    }
  }

  Future<void> _requestBooking() async {
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('fill_all_fields')).tr()),
      );
      return;
    }

    DateTime startDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    await _bookingHelper.requestBooking(
      context: context,
      playStationId: widget.playStationId,
      roomId: widget.roomId,
      startDateTime: startDateTime,
      currentMode:
          '${selectedConsole.toLowerCase()}${selectedMode == 'فردي' ? 'Single' : 'Multi'}',
      hourlyRate: hourlyRate,
      onLoadingChanged: (isLoading) {
        setState(() {
          _isLoading = isLoading;
        });
      },
      onSuccess: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: _selectTime,
          child: Text(
            selectedTime == null
                ? tr('choose_start_time').tr()
                : '${tr('start_time').tr()}: ${selectedTime!.format(context)}',
          ),
        ),
        if (!isTimeAvailable)
          Text(
            tr('time_already_booked').tr(),
            style: const TextStyle(color: Colors.red),
          ),
        const SizedBox(height: 10),
        Text(tr('choose_play_mode')).tr(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: 'فردي',
              groupValue: selectedMode,
              onChanged: (String? value) async {
                setState(() {
                  selectedMode = value!;
                });
                await _updateHourlyRate();
              },
            ),
            Text(tr('single')).tr(),
            const SizedBox(width: 30),
            Radio<String>(
              value: 'مالتي',
              groupValue: selectedMode,
              onChanged: (String? value) async {
                setState(() {
                  selectedMode = value!;
                });
                await _updateHourlyRate();
              },
            ),
            Text(tr('multi')).tr(),
          ],
        ),
        if (widget.ps4Available && widget.ps5Available) ...[
          const SizedBox(height: 10),
          Text(tr('choose_console')).tr(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio<String>(
                value: 'PS4',
                groupValue: selectedConsole,
                onChanged: (String? value) async {
                  setState(() {
                    selectedConsole = value!;
                  });
                  await _updateHourlyRate();
                },
              ),
              const Text('PS4'),
              const SizedBox(width: 30),
              Radio<String>(
                value: 'PS5',
                groupValue: selectedConsole,
                onChanged: (String? value) async {
                  setState(() {
                    selectedConsole = value!;
                  });
                  await _updateHourlyRate();
                },
              ),
              const Text('PS5'),
            ],
          ),
        ],
        Text('${tr('hourly_rate').tr()}: $hourlyRate ${tr('currency').tr()}'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isTimeAvailable ? _requestBooking : null,
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4A81C)),
                )
              : Text(tr('request_booking')).tr(),
        ),
      ],
    );
  }
}
