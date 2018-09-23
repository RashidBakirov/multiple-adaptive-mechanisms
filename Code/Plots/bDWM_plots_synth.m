    % data initialization
    nbSeries = 4;
    nbBars = 26;
    xt = 1:nbBars;
    for q=0:1
        data = res_all(1:26,1+q*4:4+q*4);

        %draw (then erase) figure and get the characteristics of Matlab bars (axis, colors...)
        fig=figure;
        hold on
        h = barh( data( :, 1 ) );
        %width = get( h, 'barWidth' );

        width =0.5
        delete( h );

        % sort in order to start painting the tallest bars
        [ sdata, idx ] = sort( data, 2 );

        % get the vertices of the different "bars", drawn as polygons
        x = [ kron( xt, [1;1] ) - width / 2; kron( xt, [1;1] ) + width / 2 ];

        % paint each layer, starting with the 'tallest' ones first
        for i = nbSeries : -1 : 1
            y = [ zeros( nbBars, 1 ), sdata( :, i ), sdata( :, i ), zeros( nbBars, 1 ) ]';
            p(i) = patch( y, x+i*0.075,  'b' );
            set( p(i), 'FaceColor', 'Flat', 'CData', idx( :, i )' );
        end

        cmacamp = colormap;    
        h = zeros(4, 1);
        h(1) = plot(0,0,'s', 'Color', 'black', 'MarkerFaceColor', cmacamp(1,:), 'visible', 'off');
        h(2) = plot(0,0,'s', 'Color', 'black', 'MarkerFaceColor',cmacamp(21,:), 'visible', 'off');
        h(3) = plot(0,0,'s', 'Color', 'black', 'MarkerFaceColor',cmacamp(43,:), 'visible', 'off');
        h(4) = plot(0,0,'s', 'Color', 'black', 'MarkerFaceColor', cmacamp(64,:),'visible', 'off');
        legend(h, 'Best AM','bDWM', 'XVSelect','XVSelectRC');
        ylabel('Dataset number');
        xlabel('Accuracy');
        title(['bDWM synthetic data. Batch size:' num2str(10*(1+q))]);
        ax = gca;
        ax.XLabel.FontSize=24;
        ax.YLabel.FontSize=24;
        ax.FontSize=13;

        ax.YTick = 1:26;
        %ax.YTickLabel=[{'27'},{'28'},{'29'},{'30'},{'31'}]
        %xlim([0.65,1])

        ylim([0,27]);
        %pbaspect([1 2 1])
        saveas(fig,['results/bDWM_synth_' num2str(10*(1+q)) '.jpg']);
    end
