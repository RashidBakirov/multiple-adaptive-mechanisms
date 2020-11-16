function significance = significanceDamien( E1, E2 )
%SIGNIFICANCEDAMIEN measure the significance between the sets of errors of
%two different estimators as per Forecast Comparison in L2 eq 18
%ftp://snde.rutgers.edu/Rutgers/wp/1995-24.pdf
U=E1-E2;
V=E1+E2;

significance=sum(U.*V)/sqrt(sum((U.^2).*(V.^2)));

end
