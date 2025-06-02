classdef NIE_plot_headmaps_v1 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        LoadButton                    matlab.ui.control.Button
        BrowseButton                  matlab.ui.control.Button
        DataTypeDropDown              matlab.ui.control.DropDown
        DataTypeDropDownLabel         matlab.ui.control.Label
        SelectDataPanel               matlab.ui.container.Panel
        TestButton                    matlab.ui.control.Button
        ResetButton                   matlab.ui.control.Button
        preview                       matlab.ui.control.CheckBox
        ColormapDropDown              matlab.ui.control.DropDown
        ColormapDropDownLabel         matlab.ui.control.Label
        GenerateButton                matlab.ui.control.Button
        scale_max                     matlab.ui.control.NumericEditField
        scale_min                     matlab.ui.control.NumericEditField
        ColormapLimitsEditFieldLabel  matlab.ui.control.Label
        tif_resolution                matlab.ui.control.NumericEditField
        TIFResolutionEditFieldLabel   matlab.ui.control.Label
        plot_print                    matlab.ui.control.CheckBox
        plot_save                     matlab.ui.control.CheckBox
        plot_close                    matlab.ui.control.CheckBox
        ExcelTabDropDown              matlab.ui.control.DropDown
        ExcelTabDropDownLabel         matlab.ui.control.Label
        Panel                         matlab.ui.container.Panel
        JackFogartyMarch2025Label     matlab.ui.control.Label
        PLOTHEADMAPSLabel             matlab.ui.control.Label
    end

    
    properties (Access = private)
        file   % Input data file
        fpath  % Input file path
        sheets % Excel sheet names
        plot_data
        plot_titles
        chan_names
        plot_scale
        plot_table
        % scale_min
        % scale_max
        % tif_resolution
        % plot_save
        % plot_close
        % plot_print
    end
    
    methods (Access = private)
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            % Options for headmap colormaps
            app.ColormapDropDown.Items = {'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', 'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag',...
                'cividis', 'inferno', 'magma', 'plasma', 'tab10', 'tab20', 'tab20b', 'tab20c', 'twilight', 'viridis',...
                'BrBG', 'PRGn', 'PiYG', 'PuOr', 'RdBu', 'RdGy', 'RdYlBu', 'RdYlGn', 'Spectral', 'Accent', 'Dark2', 'Paired', 'Pastel1', 'Pastel2', 'Set1', 'Set2', 'Set3', 'Blues', 'BuGn', 'BuPu', 'GnBu', 'Greens', 'Greys', 'OrRd', 'Oranges', 'PuBu', 'PuBuGn', 'PuRd', 'Purples', 'RdPu', 'Reds', 'YlGn', 'YlGnBu', 'YlOrBr', 'YlOrRd'...
                'thermal', 'haline', 'solar', 'ice', 'gray', 'oxy', 'deep', 'dense', 'algae', 'matter', 'turbid', 'speed', 'amp', 'tempo', 'rain', 'phase', 'topo', 'balance', 'delta', 'curl', 'diff', 'tarn'};          


        end

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)
            
            % Browse to input file
            [app.file app.fpath] = uigetfile('*.xls*');
            app.sheets           = sheetnames([app.fpath app.file]);

            % Set the sheets dropdown
            app.ExcelTabDropDown.Items = app.sheets;

        end

        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)
            
            % read in the data from the selected tab
            tmp = readtable([app.fpath app.file],"Sheet",app.ExcelTabDropDown.Value);
            app.plot_table  = tmp;
            app.plot_data   = table2array(tmp(:,2:end));
            app.plot_titles = table2cell(tmp(:,1));
            app.chan_names  = tmp.Properties.VariableNames(2:end);
            clear tmp
            
            % check and update the suggested min/max scale values
            a = floor(min(min(app.plot_data)));
            b = ceil(max(max(app.plot_data)));
            app.plot_scale = [-max(abs(a), abs(b)), max(abs(a), abs(b))];

            % Set app components
            app.scale_min.Value      = app.plot_scale(1);
            app.scale_max.Value      = app.plot_scale(2);
            app.tif_resolution.Value = 175;            
           
        end

        % Button pushed function: GenerateButton
        function GenerateButtonPushed(app, event)
            
            % Get idx to remove filename extension
            idx = find(app.file == '.')-1;

            % NIE_plot_heads(filepath,filename, data, colourmaplimits, chans, headers, plot_save, plot_close, plot_print, tif_res, chanlocs, inputcolormap, preview, type, glimpse)
            NIE_plot_heads(app.fpath,[app.file(1:idx) ' ' app.ExcelTabDropDown.Value], app.plot_table, [app.scale_min.Value app.scale_max.Value], app.chan_names, app.plot_titles, app.plot_save.Value, app.plot_close.Value, app.plot_print.Value, app.tif_resolution.Value, [], app.ColormapDropDown.Value, app.preview.Value, app.DataTypeDropDown.Value,0)

        end

        % Button pushed function: TestButton
        function TestButtonPushed(app, event)

            % Get idx to remove filename extension
            idx = find(app.file == '.')-1;

            % NIE_plot_heads(filepath,filename, data, colourmaplimits, chans, headers, plot_save, plot_close, plot_print, tif_res, chanlocs, inputcolormap, preview, type, glimpse)
            NIE_plot_heads(app.fpath,[app.file(1:idx) ' ' app.ExcelTabDropDown.Value], app.plot_table, [app.scale_min.Value app.scale_max.Value], app.chan_names, app.plot_titles, app.plot_save.Value, app.plot_close.Value, app.plot_print.Value, app.tif_resolution.Value, [], app.ColormapDropDown.Value, app.preview.Value, app.DataTypeDropDown.Value,1)

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.1059 0.4 0.3804];
            app.UIFigure.Position = [100 100 455 270];
            app.UIFigure.Name = 'MATLAB App';

            % Create Panel
            app.Panel = uipanel(app.UIFigure);
            app.Panel.BorderType = 'none';
            app.Panel.BackgroundColor = [0.149 0.149 0.149];
            app.Panel.Position = [9 188 439 75];

            % Create PLOTHEADMAPSLabel
            app.PLOTHEADMAPSLabel = uilabel(app.Panel);
            app.PLOTHEADMAPSLabel.FontSize = 36;
            app.PLOTHEADMAPSLabel.FontWeight = 'bold';
            app.PLOTHEADMAPSLabel.FontColor = [0.9412 0.9412 0.9412];
            app.PLOTHEADMAPSLabel.Position = [10 30 321 47];
            app.PLOTHEADMAPSLabel.Text = 'PLOT HEADMAPS';

            % Create JackFogartyMarch2025Label
            app.JackFogartyMarch2025Label = uilabel(app.Panel);
            app.JackFogartyMarch2025Label.FontAngle = 'italic';
            app.JackFogartyMarch2025Label.FontColor = [0.9412 0.9412 0.9412];
            app.JackFogartyMarch2025Label.Position = [11 9 143 22];
            app.JackFogartyMarch2025Label.Text = 'Jack Fogarty, March 2025';

            % Create SelectDataPanel
            app.SelectDataPanel = uipanel(app.UIFigure);
            app.SelectDataPanel.Title = 'Select Data';
            app.SelectDataPanel.BackgroundColor = [0.902 0.902 0.902];
            app.SelectDataPanel.FontWeight = 'bold';
            app.SelectDataPanel.Position = [9 11 439 135];

            % Create ExcelTabDropDownLabel
            app.ExcelTabDropDownLabel = uilabel(app.SelectDataPanel);
            app.ExcelTabDropDownLabel.HorizontalAlignment = 'right';
            app.ExcelTabDropDownLabel.Position = [5 86 60 22];
            app.ExcelTabDropDownLabel.Text = 'Excel Tab:';

            % Create ExcelTabDropDown
            app.ExcelTabDropDown = uidropdown(app.SelectDataPanel);
            app.ExcelTabDropDown.Position = [75 86 128 22];

            % Create plot_close
            app.plot_close = uicheckbox(app.SelectDataPanel);
            app.plot_close.Text = 'close figs';
            app.plot_close.Position = [361 86 72 22];

            % Create plot_save
            app.plot_save = uicheckbox(app.SelectDataPanel);
            app.plot_save.Text = 'save (.fig)';
            app.plot_save.Position = [281 86 75 22];

            % Create plot_print
            app.plot_print = uicheckbox(app.SelectDataPanel);
            app.plot_print.Text = 'export';
            app.plot_print.Position = [217 86 55 22];
            app.plot_print.Value = true;

            % Create TIFResolutionEditFieldLabel
            app.TIFResolutionEditFieldLabel = uilabel(app.SelectDataPanel);
            app.TIFResolutionEditFieldLabel.HorizontalAlignment = 'right';
            app.TIFResolutionEditFieldLabel.Position = [296 52 86 22];
            app.TIFResolutionEditFieldLabel.Text = 'TIF Resolution:';

            % Create tif_resolution
            app.tif_resolution = uieditfield(app.SelectDataPanel, 'numeric');
            app.tif_resolution.HorizontalAlignment = 'center';
            app.tif_resolution.Position = [389 52 38 22];
            app.tif_resolution.Value = 175;

            % Create ColormapLimitsEditFieldLabel
            app.ColormapLimitsEditFieldLabel = uilabel(app.SelectDataPanel);
            app.ColormapLimitsEditFieldLabel.HorizontalAlignment = 'right';
            app.ColormapLimitsEditFieldLabel.Position = [4 16 95 22];
            app.ColormapLimitsEditFieldLabel.Text = 'Colormap Limits:';

            % Create scale_min
            app.scale_min = uieditfield(app.SelectDataPanel, 'numeric');
            app.scale_min.HorizontalAlignment = 'center';
            app.scale_min.Position = [114 16 40 22];

            % Create scale_max
            app.scale_max = uieditfield(app.SelectDataPanel, 'numeric');
            app.scale_max.HorizontalAlignment = 'center';
            app.scale_max.Position = [163 16 40 22];

            % Create GenerateButton
            app.GenerateButton = uibutton(app.SelectDataPanel, 'push');
            app.GenerateButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateButtonPushed, true);
            app.GenerateButton.Position = [296 16 64 23];
            app.GenerateButton.Text = 'Generate';

            % Create ColormapDropDownLabel
            app.ColormapDropDownLabel = uilabel(app.SelectDataPanel);
            app.ColormapDropDownLabel.HorizontalAlignment = 'right';
            app.ColormapDropDownLabel.Position = [5 52 60 22];
            app.ColormapDropDownLabel.Text = 'Colormap:';

            % Create ColormapDropDown
            app.ColormapDropDown = uidropdown(app.SelectDataPanel);
            app.ColormapDropDown.Position = [75 52 128 22];

            % Create preview
            app.preview = uicheckbox(app.SelectDataPanel);
            app.preview.Text = 'preview';
            app.preview.Position = [217 52 63 22];
            app.preview.Value = true;

            % Create ResetButton
            app.ResetButton = uibutton(app.SelectDataPanel, 'push');
            app.ResetButton.Position = [365 16 64 23];
            app.ResetButton.Text = 'Reset';

            % Create TestButton
            app.TestButton = uibutton(app.SelectDataPanel, 'push');
            app.TestButton.ButtonPushedFcn = createCallbackFcn(app, @TestButtonPushed, true);
            app.TestButton.Position = [227 16 64 23];
            app.TestButton.Text = 'Test';

            % Create DataTypeDropDownLabel
            app.DataTypeDropDownLabel = uilabel(app.UIFigure);
            app.DataTypeDropDownLabel.HorizontalAlignment = 'right';
            app.DataTypeDropDownLabel.FontWeight = 'bold';
            app.DataTypeDropDownLabel.FontColor = [0.902 0.902 0.902];
            app.DataTypeDropDownLabel.Position = [271 156 61 22];
            app.DataTypeDropDownLabel.Text = 'Data Type';

            % Create DataTypeDropDown
            app.DataTypeDropDown = uidropdown(app.UIFigure);
            app.DataTypeDropDown.Items = {'EEG', 'fNIRS'};
            app.DataTypeDropDown.BackgroundColor = [0.902 0.902 0.902];
            app.DataTypeDropDown.Position = [347 156 100 22];
            app.DataTypeDropDown.Value = 'EEG';

            % Create BrowseButton
            app.BrowseButton = uibutton(app.UIFigure, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Position = [9 155 100 23];
            app.BrowseButton.Text = 'Browse';

            % Create LoadButton
            app.LoadButton = uibutton(app.UIFigure, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.Position = [116 155 100 23];
            app.LoadButton.Text = 'Load';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = NIE_plot_headmaps_v1

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end