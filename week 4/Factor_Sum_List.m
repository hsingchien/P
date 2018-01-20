function  U = Factor_Sum_List( F )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
U = struct('var',[],'card',[],'val',[]);
for i = 1:length(F)
    U = FactorSum_V2(U,F(i));
end

end

