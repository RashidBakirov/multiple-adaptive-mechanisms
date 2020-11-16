function drawNemenyi(Results,Names,OutFolder,OutName)

figure(1)
cd = fsCD(Results);
Ne = size(Results,2);
for i = 1:size(Results,1)
    Ran(i,:) = tiedrank(Results(i,:));
end
plot([1 Ne],[0 0],'k')
hold on
plot(1:Ne,zeros(1,Ne),'k+')
xlim([-1 Ne+2])
plot(mean(Ran),zeros(1,Ne),'r.')
if Ne > 8
    ylim([-0.4 0.3])
else
    ylim([-0.3 0.3])
end
[RanSort,RanIndx] = sort(mean(Ran),'ascend');
divInd = round(length(RanSort)/2);
LinSpa = 0.05;

for i = 1:divInd
    
    plot([RanSort(i) RanSort(i)],[-0.01 -0.01-(i*LinSpa)],'r')
    plot([1 RanSort(i)],[-0.01-(i*LinSpa) -0.01-(i*LinSpa)],'r')
    text(0.9,-0.01-(i*LinSpa),char(Names(RanIndx(i))),'HorizontalAlignment','right')
end

i = 1;
for c = length(RanSort):-1:divInd+1
    
    plot([RanSort(c) RanSort(c)],[-0.01 -0.01-(i*LinSpa)],'r')
    plot([RanSort(c) Ne],[-0.01-(i*LinSpa) -0.01-(i*LinSpa)],'r')
    text(Ne+.1,-0.01-(i*LinSpa),char(Names(RanIndx(c))))
    i = i+1;
end
for i = 1:length(RanSort)
    text(i-0.08,0.035,num2str(i),'FontSize',7,'VerticalAlignment','top')
end

h=plot([1 1],[0.048 0.052]);
plot([1+cd 1+cd],[0.048 0.052],'Color',h.Color);
plot([1 1+cd],[0.05 0.05],'Color',h.Color);
text(1, 0.05+0.02, 'CD','Color',h.Color)

%% Draw significant lines
Temp = Results(:,RanIndx);
[p, Nemenyi, meanrank, CDa, rankmean, p2, Fr, Cv] = nemenyi(Temp, 1);
if p<0.05 || (p==99999 && Fr>Cv)
    
    
    NEM = tril(Nemenyi==1);
    Ind = zeros(1,size(NEM,2));
    for i = 1:size(NEM,2)
        [aa,bb] = find(NEM(:,i)==0);
        if numel(aa)~=0;Ind(i) = aa(end);end
    end
    
    [C,ia,ic] = unique(Ind);
    count = 1;
    for i = ia' %size(unique(Ind),1)
        if Ne > 1 % change this to 4 later
            if mod(count,2)==0
                plot([RanSort(i) RanSort(C(count))],...
                    [-0.01-(2*LinSpa*0.4) -0.01-(2*LinSpa*0.4)]);
            else
                plot([RanSort(i) RanSort(C(count))],...
                    [-0.01-(LinSpa*0.4) -0.01-(LinSpa*0.4)]);
            end
            count=count+1;
        else
            error('Matrix size is can not be Nx1')
        end
        
    end
end
%title(['Friedman p = ' num2str(p)])
if p==99999
    if Fr>Cv
        lbl=['Fr=' num2str(Fr) ' > Cv=' num2str(Cv)];
    elseif Fr==Cv
        lbl=['Fr=' num2str(Fr) ' = Cv=' num2str(Cv)];
    else
        lbl=['Fr=' num2str(Fr) ' < Cv=' num2str(Cv)];
    end
    text(0.2, 0.125, lbl)        
else
    text(0.2, 0.125, ['Friedman p = ' num2str(p)])
end
%xlabel(['Friedman p = ' num2str(p)])

%% print
% box off
 axis off
% set(gca,'LineWidth',0.75,'FontSize',8,'FontName','Arial');
% set(gcf, 'PaperUnits', 'centimeters');
% set(gcf, 'PaperPosition', [0 0 12 8]);
%print('-dtiff' ,'-r600',[OutFolder '/' OutName '.tif'])
% close(1)