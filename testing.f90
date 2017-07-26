program testing
  use ieee_arithmetic
  integer, parameter :: i8 = selected_int_kind(13)
  integer, parameter :: r8 = selected_real_kind(12)
  integer(i8), parameter :: dsnan_pat = int(Z'7FF4000000000000',i8)
  real(r8) :: my_nan

  print *, 'ieee_support_nan: ', ieee_support_nan()
  my_nan = transfer(dsnan_pat, my_nan)
  print *, 'my_nan ieee_class: ', ieee_class(my_nan)
  print *, 'ieee_class(my_nan) == ieee_signaling_nan: ', ieee_class(my_nan) == ieee_signaling_nan
  print *, 'my_nan ieee_is_nan: ', ieee_is_nan(my_nan)

end program testing
