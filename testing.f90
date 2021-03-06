program testing
  use ieee_arithmetic
  integer, parameter :: i8 = selected_int_kind(13)
  integer, parameter :: r8 = selected_real_kind(12)
  integer(i8), parameter :: dsnan_pat = int(Z'7FF4000000000000',i8)
  integer(i8), parameter :: dqnan_pat = int(Z'7FF8000000000000',i8)
  real(r8) :: my_nan
  type(ieee_class_type) :: my_class
  character(len=64) :: mode
  character(len=64) :: check_method
  logical :: my_result

  call get_command_argument(1, mode)
  call get_command_argument(2, check_method)

  print *, 'ieee_support_nan: ', ieee_support_nan()

  select case (mode)
  case('transfer_qnan')
     print *, 'With transfer of dqnan: '
     my_nan = transfer(dqnan_pat, my_nan)
  case('transfer_snan')
     print *, 'With transfer of dsnan: '
     my_nan = transfer(dsnan_pat, my_nan)
  case('ieee_qnan')
     print *, 'With ieee_value of ieee_quiet_nan: '
     my_nan = ieee_value(my_nan, ieee_quiet_nan)
  case('ieee_snan')
     print *, 'With ieee_value of ieee_signaling_nan: '
     my_nan = ieee_value(my_nan, ieee_signaling_nan)
  case default
     print *, 'first argument should be one of: transfer_qnan, transfer_snan, ieee_qnan or ieee_snan'
  end select

  select case (check_method)
  case('ieee_is_nan')
     print *, 'about to call ieee_is_nan'
     print *, 'ieee_is_nan: ', ieee_is_nan(my_nan)
  case('isnan')
     print *, 'about to call isnan'
     print *, 'isnan: ', isnan(my_nan)
  case('ieee_class')
     print *, 'about to call ieee_class'
     my_class = ieee_class(my_nan)
     if (my_class == ieee_signaling_nan) then
        print *, 'signaling nan'
     else if (my_class == ieee_quiet_nan) then
        print *, 'quiet nan'
     else if (my_class == ieee_other_value) then
        print *, 'other value'
     else
        print *, 'UNKNOWN'
     end if
  case('isnan_not_equal_to_self')
     print *, 'about to call isnan_not_equal_to_self'
     my_result = isnan_not_equal_to_self(my_nan)
     print *, 'isnan_not_equal_to_self = ', my_result
  case('isnan_equal_to_self')
     print *, 'about to call isnan_equal_to_self'
     my_result = isnan_equal_to_self(my_nan)
     print *, 'isnan_equal_to_self = ', my_result
  case('isnan_transfer_to_real')
     print *, 'about to call isnan_transfer_to_real'
     my_result = isnan_transfer_to_real(my_nan)
     print *, 'isnan_transfer_to_real = ', my_result
  case('isnan_transfer_to_int')
     print *, 'about to call isnan_transfer_to_int'
     my_result = isnan_transfer_to_int(my_nan)
     print *, 'isnan_transfer_to_int = ', my_result
  case default
     print *, 'second argument should be one of: ieee_is_nan, isnan, ieee_class, isnan_not&
          &_equal_to_self, isnan_equal_to_self, isnan_transfer_to_real, isnan_transfer_to_int'
  end select

contains
  logical function isnan_not_equal_to_self(val)
    real(r8), intent(in) :: val
    print *, 'in isnan_not_equal_to_self'
    if (val /= val) then
       isnan_not_equal_to_self = .true.
    else
       isnan_not_equal_to_self = .false.
    end if
  end function isnan_not_equal_to_self

  logical function isnan_equal_to_self(val)
    real(r8), intent(in) :: val
    print *, 'in isnan_equal_to_self'
    if (val == val) then
       isnan_equal_to_self = .false.
    else
       isnan_equal_to_self = .true.
    end if
  end function isnan_equal_to_self

  logical function isnan_transfer_to_real(val)
    real(r8), intent(in) :: val
    print *, 'in isnan_transfer_to_real'
    isnan_transfer_to_real = (val == transfer(dqnan_pat, val) .or. val == transfer(dsnan_pat, val))
  end function isnan_transfer_to_real

  logical function isnan_transfer_to_int(val)
    real(r8), intent(in) :: val
    integer(i8) :: val_as_int

    print *, 'in isnan_transfer_to_int'
    val_as_int = transfer(val, val_as_int)
    isnan_transfer_to_int = (val_as_int == dsnan_pat .or. val_as_int == dqnan_pat)
  end function isnan_transfer_to_int

end program testing
