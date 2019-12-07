function f = hrfgammadouble(params,x)

% function f = hrfgammadouble(params,x)
%
% <params> is [n1 t1 a1 n2 t2 a2 d o] where
%   <n1> is the power
%   <t1> is the time constant for the exponential
%   <a1> is the amplitude
%   <n2> is the power
%   <t2> is the time constant for the exponential
%   <a2> is the amplitude
%   <d> is the delay from 0, such that the entire double gamma
%     is shifted forward by <d> and then any x-values less than
%     <d> get assigned a y-value of <o>
%   <o> is the offset
% <x> is a vector of values
%
% evaluate the double-gamma function at <x>.

% calc
n1 = params(1);
t1 = params(2);
a1 = params(3);
n2 = params(4);
t2 = params(5);
a2 = params(6);
d  = params(7);
o  = params(8);

% evaluate
temp = x-d;
f = a1 * temp.^n1 .* exp(-temp/t1) + a2 * temp.^n2 .* exp(-temp/t2) + o;
f(x<d) = o;
