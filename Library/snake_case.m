function out = snake_case(in)

in2 = strrep(in, ' ', '_');
out = strrep(in2, '-', '_');