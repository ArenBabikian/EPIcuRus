% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
%IMPLODE    Joins strings with delimiter in between.

function string=implode(pieces,delimiter)


if isempty(pieces) % no pieces to join, return empty string
   string='';
   
else % no need for delimiters yet, so far there's only one piece
   string=pieces{1};   
end

l=length(pieces);
p=1;
while p<l % more than one piece to join with the delimiter, the interesting case
   p=p+1;
   %string=strcat(string,delimiter,pieces{p});
   string=[string,delimiter,pieces{p}];
end
