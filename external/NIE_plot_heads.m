%% Plot PCA headmaps
%
% Code adapted from PCA_plot_headmaps function developed by Dr Frances De Blasio [email: francesd@uow.edu.au]
% Altered to enable:
%   1. limited plotting of fNIRS montage
%   2. Increased flexibility with EEG montage
%   3. Allow print preview without save
%   4. Colormap selection

function NIE_plot_heads(filepath,filename, data, colourmaplimits, chans, headers, plot_save, plot_close, plot_print, tif_res, chanlocs, inputcolormap, preview, type, glimpse)

if strcmp(type,'fNIRS')
    
    % Switch to fNIRS function
    fnirs_heatmap_flex(filepath,filename, data, colourmaplimits, chans, headers, plot_save, plot_close, plot_print, tif_res, chanlocs, inputcolormap, preview, type, glimpse);

else
    
    % Convert data format
    data = table2array(data(:,2:end));

    % load the default channel location data if not already preloaded
    if isempty(chanlocs)
        [file,  path] = uigetfile('*.*','Load chanloc file');
        chanlocs = readlocs([path file]);
    elseif strcmp(chanlocs,'Default')
        load('chanlocs.mat') % Uk_project_chanlocs.mat for the uk project    
    end
    
    % check the channel order of the channel location file
    chanorder = cell(1,length(chanlocs)); %#ok<NODEF>
    for y = 1:length(chanlocs)
        chanorder{y} = chanlocs(y).labels;
    end
    clear y
    
    % locate the index of the data channels in relation to the chanlocs data
    idx = zeros(1,length(chans));
    for y = 1:length(chans)
        % check and rename if older nameing used for temporal sites
        if strcmpi(chans{y},'T3') || strcmpi(chans{y},'T3(T7)') || strcmpi(chans{y},'T7(T3)')
            chans{y} = 'T7';
        elseif strcmpi(chans{y},'T5')
            chans{y} = 'P7';
        elseif strcmpi(chans{y},'T4') || strcmpi(chans{y},'T4(T8)') || strcmpi(chans{y},'T8(T4)')
            chans{y} = 'T8';
        elseif strcmpi(chans{y},'T6')
            chans{y} = 'P8';
        elseif strcmpi(chans{y},'p08')
            chans{y} = 'PO8';
        end
        idx(y) = find(strcmpi(chans{y},chanorder));
    end
    chanlocs = chanlocs(idx);
    clear y idx chanorder chans
    
    % make the headmaps
    for x = 1:size(data,1) % for each dataset

        fig = figure('Name', [filename ' ' headers{x}],'NumberTitle','off');
        set(fig,'Position', [50,500,400,450])
        UoW_topoplot_v2(data(x,:),chanlocs, 'maplimits', colourmaplimits, 'whitebk', 'on');
        
        % Break circuit if Preview callback was used to glimpse the 1st headmap
        if glimpse
            movegui(gcf,'center')
            ft_colormap(inputcolormap)
            break
        end

        % save headmaps if this option was selected
        if plot_save == 1
            if x == 1
                % check and make sure the output folder exists
                if ~exist('headmaps\figs\', 'dir')
                    mkdir('headmaps\figs\')
                end
            end
            % save the figure    
            saveas(fig,['headmap figs\' filename ' ' headers{x} ' (' num2str(colourmaplimits(1)) ' to ' num2str(colourmaplimits(2)) ').fig'])
        end
        
        % print the headmap if this option was selected
        if plot_print == 1
            if x == 1
                % check and make sure the output folder exists
                if ~exist([filepath 'headmaps\col headmaps\'],'dir')
                    mkdir(filepath, 'headmaps\col headmaps\')
                    mkdir(filepath, 'headmaps\b&w headmaps\')
                end
            end
            set(gcf, 'Color', 'w'); % set background colour to white
            ft_colormap(inputcolormap)
            movegui(gcf,'center')
            
            % Export color map
            export_fig([filepath 'headmaps\col headmaps\' filename ' '  ' ' headers{x} ' (' num2str(colourmaplimits(1)) ' to ' num2str(colourmaplimits(2)) ')'], '-tif', ['-r' num2str(tif_res)])
            
            % Export gray map
            load('GreyCmapSettings', 'mycmap');
            set(gcf, 'Colormap', mycmap)
            export_fig([filepath 'headmaps\b&w headmaps\' filename ' '  ' ' headers{x} ' (' num2str(colourmaplimits(1)) ' to ' num2str(colourmaplimits(2)) ')'], '-tif', '-CMYK', ['-r' num2str(tif_res*2)])
            ft_colormap(inputcolormap)
            
        elseif plot_print ~= 1 && preview == 1
            movegui(gcf,'center')
        end
        
        % close the headmap figure if this option was selected
        if plot_close == 1
            close(fig)
        end
    end
end