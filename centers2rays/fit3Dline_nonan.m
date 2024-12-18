function [xyz0,direction]=fit3Dline_nonan(XYZ)
%% [xyz0,direction]=fit3Dline_jv(XYZ)
% 
% @JVessaire 01/2019

xyz0=mean(XYZ,1);
Aa=bsxfun(@minus,XYZ,xyz0); %center the data
xyz0 = squeeze(xyz0);

%Aa=permute(A,[3 2 1]); %c'est b�te de pas faire �a ....mais il y a la projection de (X,Y)px par calib plan � plan (kplan X Y)rw

[~, ~, Vac]=arrayfun(@(kkk) svd(Aa(:,:,kkk)),[1:size(Aa,3)],'UniformOutput',false);
Va=cat(3,Vac{:}); 

dd=arrayfun(@(x) cross(Va(:,end,x),Va(:,end-1,x)),[1:size(Va,3)],'UniformOutput',false);
direction=cat(2,dd{:})';  clear dd Vac A;