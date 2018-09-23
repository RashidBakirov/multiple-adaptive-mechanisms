    % data initialization
    nbSeries = 3;
    nbBars = 3;
    xt = 1:nbBars;
    
    for q=0:2
    
        data = res_all(:,1+q*3:3+q*3);

        %draw (then erase) figure and get the characteristics of Matlab bars (axis, colors...)
        fig=figure;
        hold on
        h = bar( data( :, 1 ) );
        width = get( h, 'barWidth' );
        delete( h );

        % sort in order to start painting the tallest bars
        [ sdata, idx ] = sort( data, 2 );

        % get the vertices of the different "bars", drawn as polygons
        x = [ kron( xt, [1;1] ) - width / 2; kron( xt, [1;1] ) + width / 2 ];

        % paint each layer, starting with the 'tallest' ones first
        for i = nbSeries : -1 : 1
            y = [ zeros( nbBars, 1 ), sdata( :, i ), sdata( :, i ), zeros( nbBars, 1 ) ]';
            p(i) = patch( x+i*0.05, y, 'b' );
            set( p(i), 'FaceColor', 'Flat', 'CData', idx( :, i )' );
        end


        h = zeros(3, 1);
        h(1) = plot(0,0,'s', 'Color', 'black', 'MarkerFaceColor', cmacamp(1,:), 'visible', 'off');
        h(2) = plot(0,0,'s', 'Color', 'black', 'MarkerFaceColor',cmacamp(32,:), 'visible', 'off');
        h(3) = plot(0,0,'s', 'Color', 'black', 'MarkerFaceColor', cmacamp(64,:),'visible', 'off');
        legend(h, 'Best AM','XVSelect','XVSelectRC');
        ylabel('Normalised MAE')
        xlabel('Dataset number')
        title(['SABLE. Batch size:' num2str(50*(2^q))])
        a = gca;
        a.XTick = 1:3
        a.XTickLabel = [1,4,5]
        %ylim([0.25,0.45])
        
        saveas(fig,['results/SABLE_' num2str(50*(2^q)) '.jpg'])
    end