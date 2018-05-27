function [ Data ] = FixPolarRange( Data,min_val,max_val )
%UNTITLED3 Summary of this function goes here


    Range_Val = max_val - min_val;
    Avg_Val = min_val + (max_val - min_val)/2;
    [val1 ind1]=find(Data<min_val);
    Data(ind1) = Data(ind1) + Range_Val * floor(abs(Data(ind1)-max_val)/Range_Val);
    [val2 ind2]=find(Data>max_val);
    Data(ind2) = Data(ind2) - Range_Val * floor(abs(Data(ind2)-min_val)/Range_Val);
 
end
