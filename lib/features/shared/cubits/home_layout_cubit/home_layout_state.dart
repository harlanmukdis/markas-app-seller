part of 'home_layout_cubit.dart';

abstract class HomeLayoutState {}

class HomeViewInitial extends HomeLayoutState {}

class ChangeLocalState extends HomeLayoutState {}

class HomeChangeBottomNav extends HomeLayoutState {}

class Error extends HomeLayoutState {
  final String error;

  Error(this.error);
}
