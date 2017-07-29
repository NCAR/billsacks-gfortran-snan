=================================
 Overview, compiling and running
=================================

The code here tests NaN-handling in gfortran, tied in with
https://github.com/ESMCI/cime/issues/1763

Compile with either:

- No NaN checks::

    gfortran testing.f90

- With NaN checks::

    gfortran -ffpe-trap=invalid testing.f90

The resulting executable takes two arguments::

  ./a.out mode check_method

``mode`` determines how the variable is set to NaN; it can be one of:

- ``transfer_qnan``: sets variable to quiet NaN using a transfer function

- ``transfer_snan``: sets variable to signaling NaN using a transfer function

- ``ieee_qnan``: sets variable to quiet NaN using ieee_value

- ``ieee_snan``: sets variable to signaling NaN using ieee_value

``check_method`` determines the method for checking if the variable is NaN; it can be one of:

- ``ieee_is_nan``: ieee_arithmetic's ieee_is_nan function

- ``isnan``: gfortran's isnan function

- ``ieee_class``: ieee_arithmetic's ieee_class function

- ``isnan_not_equal_to_self``: function that checks ``val /= val``

- ``isnan_equal_to_self``: function that checks ``val == val``

- ``isnan_transfer_to_real``: function that compares ``val`` with a bit pattern transferred to a real

- ``isnan_transfer_to_int``: function that transfers ``val`` to a bit pattern stored in an int, then compares against known bit patterns

============
Testing done
============

I tested many combinations of the above options on the following three platforms:

- MacBook Pro with gfortran 5.4.0 (gives ``ieee_support_nan`` as false)

- NCAR's cheyenne machine with gfortran 6.3.0 (gives ``ieee_support_nan`` as false)

- NCAR's cheyenne machine with gfortran 7.1.0 (gives ``ieee_support_nan`` as true)


===========
Conclusions
===========

Item (1) seems like incorrect behavior. Items (2) and (3) make ``-ffpe-trap=invalid`` impossible to use with any code that legitimately wants to check for NaN values. Item (4) addresses my original question.

1. With all three versions of gfortran - even 7.1.0 which claims to have ``ieee_support_nan`` true - signaling NaNs are identified as quiet NaNs by ieee_class::

     $ gfortran testing.f90

     $ ./a.out ieee_snan ieee_class
      ieee_support_nan:  T
      With ieee_value of ieee_signaling_nan:
      about to call ieee_class
      quiet nan

     $ ./a.out transfer_snan ieee_class
      ieee_support_nan:  T
      With transfer of dsnan:
      about to call ieee_class
      quiet nan

   (ifort 17.0.1 correctly identified these as signaling NaNs.)

   I tried recompiling with ``-fsignaling-nans`` and got the same result (with 5.4.0 and 7.1.0).

2. With all three versions of gfortran - even 7.1.0 which claims to have ``ieee_support_nan`` true - if I compile with ``-ffpe-trap=invalid``, I get a floating point exception when trying to load a NaN into a variable with ``ieee_value(my_nan, ieee_quiet_nan)`` or ``ieee_value(my_nan, ieee_signaling_nan)``::

     $ gfortran -ffpe-trap=invalid testing.f90

     $ ./a.out ieee_qnan ieee_is_nan
      ieee_support_nan:  T
      With ieee_value of ieee_quiet_nan:

      Program received signal SIGFPE: Floating-point exception - erroneous arithmetic operation.

      Backtrace for this error:
      #0  0x7fffec63913f in ???
      #1  0x7fffed6b4c18 in __ieee_arithmetic_MOD_ieee_value_8
      at ../../../gcc-7.1.0/libgfortran/ieee/ieee_arithmetic.F90:906
      #2  0x4010e4 in ???
      #3  0x401d26 in ???
      #4  0x7fffec625b24 in ???
      #5  0x400c88 in ???
      at ../sysdeps/x86_64/start.S:122
      #6  0xffffffffffffffff in ???
      Floating point exception (core dumped)

   Recompiling with ``-fsignaling-nans`` did not change this (tested with 7.1.0).

3. With all three versions of gfortran - even 7.1.0 which claims to have ``ieee_support_nan`` true - if I compile with ``-ffpe-trap=invalid``, I get a floating point exception when trying to call ieee_is_nan, gfortran's isnan, or ieee_class on a signaling NaN (loaded into a variable via the transfer function)::

     $ gfortran -ffpe-trap=invalid testing.f90

     $ ./a.out transfer_snan ieee_is_nan
      ieee_support_nan:  T
      With transfer of dsnan:
      about to call ieee_is_nan

      Program received signal SIGFPE: Floating-point exception - erroneous arithmetic operation.

      Backtrace for this error:
      #0  0x7fffec63913f in ???
      #1  0x4012d2 in ???
      #2  0x401d26 in ???
      #3  0x7fffec625b24 in ???
      #4  0x400c88 in ???
      at ../sysdeps/x86_64/start.S:122
      #5  0xffffffffffffffff in ???
      Floating point exception (core dumped)

   Recompiling with ``-fsignaling-nans`` did not change this (tested with 7.1.0).

4. To answer the original question of how we can check for NaN values (signaling or quiet) when compiling with ``-ffpe-trap=invalid``: It appears that the only approach is the one given in ``isnan_transfer_to_int``; this works for quiet and signaling NaNs on the three tested versions of gfortran. The others have the following problems:

   - ``ieee_is_nan``: floating point exception

   - ``isnan``: floating point exception

   - ``ieee_class``: floating point exception

   - ``isnan_not_equal_to_self``: floating point exception

   - ``isnan_equal_to_self``: floating point exception

   - ``isnan_transfer_to_real``: returns False even for a NaN value - maybe because a NaN never equals itself?

   Recompiling with ``-fsignaling-nans`` did not change these results, EXCEPT that ``isnan_transfer_to_real`` gave a floating point exception rather than an incorrect answer (tested with 7.1.0).


   *Update:* It turns out that even the ``isnan_transfer_to_int`` method is not robust, because NaNs have many possible bit representations.
   A more robust method would be to check if the given value is in the range of possible bit representations, but that's starting to feel fragile:
   I'm concerned that there may be some machines that don't follow the IEEE standard in this respect, and so the function would give the wrong answer.

   I tried going to go with a different solution: changing the compilation flags for shr\_infnan\_mod so that we avoid adding ``-ffpe-trap=invalid`` for that one module.
   But that didn't work either: see https://github.com/ESMCI/cime/issues/1763#issuecomment-318802211

   So I'm at a loss as to what to do here.
