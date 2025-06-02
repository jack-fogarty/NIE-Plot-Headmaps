function fnirs_heatmap_flex(filepath,filename, data, colourmaplimits, chans, headers, plot_save, plot_close, plot_print, tif_res, chanlocs, inputcolormap, preview, type, glimpse)

    % Load the optode layout if not already preloaded
    if isempty(chanlocs)
        [file,  path] = uigetfile('*.*');
        layout = importdata([path file]);
    elseif strcmp(chanlocs,'Default')
        % Brite24 2x12 Optode setup is the current default
        load('C:\Users\jfogarty\OneDrive - Nanyang Technological University\1. Research Projects\a. PI Projects\3. NCC-SRL\1. MW Project\URECA 2022\2. Raw Data\brite24_ft_layout.mat');
    end
   
    % What are we plotting? (HbO, HbR, or HbT?)
    label = layout.label(1:3:72); % HbO
    
    % Select the channels in the data that match with the layout:
    [seldat, sellay] = match_str(label, layout.label);
    if isempty(seldat)
      ft_error('labels in data and labels in layout do not match');
    end
    clear seldat
    
    % Select x and y coordinates and labels of the channels in the data
    chanX = layout.pos(sellay,1);
    chanY = layout.pos(sellay,2);

    % Load the topoplot options for the Brite24 setup
    opt = {'interpmethod', 'v4','interplim','mask','gridscale',532,'outline',layout.outline,'shading','flat','isolines',6,'mask',layout.mask,'style','surfiso','datmask',[]};    
    
%     opt = {'interpmethod', cfg.interpolation, ...
%     'interplim',    interplimits, ...
%     'gridscale',    cfg.gridscale, ...
%     'outline',      cfg.layout.outline, ...
%     'shading',      cfg.shading, ...
%     'isolines',     cfg.contournum, ...
%     'mask',         cfg.layout.mask, ...
%     'style',        style, ...
%     'datmask',      msk};

    % Grab cmap limits and relevant data
    if istable(data)
        data = table2cell(data);
    end

    % Set colourmaplimits if it is empty
    if isempty(colourmaplimits)
        colourmaplimits = [min(cell2mat(data(2:end,2:end)),[],'all') max(cell2mat(data(2:end,2:end)),[],'all')];
    end
    
    % Get plot names 'headers'
    headers = data(:,1);
    
    for i = 1:(size(data(:,:),1))
        
        tmp = cell2mat(data(i,2:25)); % Grab the data for this
    
        % Plot the figure
        figure; ft_plot_topo(chanX, chanY, tmp, opt{:});
        ft_plot_layout(layout, 'box', 'no', 'label', 'no', 'point', 'no'); % Add the border around the plot

        % Add the border and channel markers
        channelsToMark = 1:length(label);
        labelflg = 0;
        
        templay = [];
        templay.outline = layout.outline;
        templay.mask    = layout.mask;
        templay.pos     = layout.pos(sellay,:);
        templay.width   = layout.width(sellay);
        templay.height  = layout.height(sellay);
        templay.label   = layout.label(sellay);

        ft_plot_layout(templay, 'box', 'no', 'label',labelflg, 'point', ~labelflg, ...
          'pointsymbol',  '.', ...
          'pointcolor',   [0 0 0], ...
          'pointsize',    20, ...
          'fontsize',     8, ...
          'labeloffset',  0.005, ...
          'labelalignh', 'center', ...
          'labelalignv', 'middle');
      
        % Change colormap limits
        caxis(colourmaplimits);
        
        % Do we want to print?
        % plot_print = 1;
        
        % Then close?
        % plot_close = 1;

        % Break circuit if Preview callback was used to glimpse the 1st headmap
        if glimpse
            movegui(gcf,'center')
            ft_colormap(inputcolormap)
            break
        end
        
        % Current path
        datafile = [cd '\headmaps\'];
        
        % Tif resolution
        tif_res = 175; % Seems to be the default in Make_headmaps
      
        % print the headmap if this option was selected
        if plot_print == 1   
            if i == 1
                % check and make sure the output folder exists
                if ~exist([datafile 'col headmaps\'], 'dir')
                    mkdir('col headmaps\')
                    mkdir('b&w headmaps\')
                end
            end
            set(gcf, 'Color', 'w'); % set background colour to white
            colormap parula
            export_fig([datafile 'col headmaps\' ' '  ' ' headers{i} ' (' num2str(colourmaplimits(1)) ' to ' num2str(colourmaplimits(2)) ')'], '-tif', ['-r' num2str(tif_res)])
            %colormap gray
            load('GreyCmapSettings', 'mycmap');
            set(gcf, 'Colormap', mycmap)
            export_fig([datafile 'b&w headmaps\' ' '  ' ' headers{i} ' (' num2str(colourmaplimits(1)) ' to ' num2str(colourmaplimits(2)) ')'], '-tif', '-CMYK', ['-r' num2str(tif_res*2)])
        end

        % close the headmap figure if this option was selected
        if plot_close == 1
            close
        end
    end
end
      
      
      

    %     ft_plot_layout(templay, 'box', 'no', 'label',labelflg, 'point', ~labelflg, ...
    %       'pointsymbol',  '.', ...
    %       'pointcolor',   cfg.markercolor, ...
    %       'pointsize',    cfg.markersize, ...
    %       'fontsize',     cfg.markerfontsize, ...
    %       'labeloffset',  cfg.labeloffset, ...
    %       'labelalignh', 'center', ...
    %       'labelalignv', 'middle');
    
    
    

% TO CHANGE THE COLOUR LIMITS SIMPLY WRITE:
% caxis([new_min new_max]);
% caxis(lims);

% TO CHANGE THE COLOUR MAP YOU CAN:
% ft_colormap('gray')
% ft_colormap('jet')
% ft_colormap('parula')
% ft_colormap('turbo')
% ft_colormap('cool')
% ft_colormap('spring')
% ft_colormap('winter')
% ft_colormap('summer')
% ft_colormap('copper')
% ft_colormap('pink')
% ft_colormap('bone')
% ft_colormap('cividis')
% ft_colormap('viridis')
% ft_colormap('twilight')
% ft_colormap('thermal')
% ft_colormap('haline')
% ft_colormap('solar')
% ft_colormap('ice')
% ft_colormap('oxy')
% ft_colormap('deep')
% ft_colormap('dense')
% ft_colormap('matter')
% ft_colormap('curl')
