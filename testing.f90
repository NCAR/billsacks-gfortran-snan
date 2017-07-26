program testing
  use ieee_arithmetic
  integer, parameter :: i8 = selected_int_kind(13)
  integer, parameter :: r8 = selected_real_kind(12)
  integer(i8), parameter :: dsnan_pat = int(Z'7FF4000000000000',i8)
  integer(i8), parameter :: dqnan_pat = int(Z'7FF8000000000000',i8)
  real(r8) :: my_nan
  character(len=64) :: mode

  call get_command_argument(1, mode)

  print *, 'ieee_support_nan: ', ieee_support_nan()

  select case (mode)
  case('transfer_qnan')
     print *, 'With transfer of dqnan: '
     my_nan = transfer(dqnan_pat, my_nan)
     call print_info(my_nan)
  case('transfer_snan')
     print *, 'With transfer of dsnan: '
     my_nan = transfer(dsnan_pat, my_nan)
     call print_info(my_nan)
  case('ieee_qnan')
     print *, 'With ieee_value of ieee_quiet_nan: '
     my_nan = ieee_value(my_nan, ieee_quiet_nan)
     call print_info(my_nan)
  case('ieee_snan')
     print *, 'With ieee_value of ieee_signaling_nan: '
     my_nan = ieee_value(my_nan, ieee_signaling_nan)
     call print_info(my_nan)
  case default
     print *, 'call with one argument: transfer_qnan, transfer_snan, ieee_qnan or ieee_snan'
  end select

contains
  subroutine print_info(var)
    real(r8) :: var
    type(ieee_class_type) :: my_class

    print *, 'ieee_is_nan: ', ieee_is_nan(var)

    my_class = ieee_class(var)
    if (my_class == ieee_signaling_nan) then
       print *, 'signaling nan'
    else if (my_class == ieee_quiet_nan) then
       print *, 'quiet nan'
    else if (my_class == ieee_other_value) then
       print *, 'other value'
    else
       print *, 'UNKNOWN'
    end if

  end subroutine print_info

end program testing
