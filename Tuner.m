classdef Tuner < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure          matlab.ui.Figure
        GridLayout        matlab.ui.container.GridLayout
        LeftPanel         matlab.ui.container.Panel
        EditField_chord_guage matlab.ui.control.EditField
        Gauge             matlab.ui.control.SemicircularGauge
        GaugeLabel        matlab.ui.control.Label
        TabGroup          matlab.ui.container.TabGroup
        Tab               matlab.ui.container.Tab
        Image             matlab.ui.control.Image
        Image2            matlab.ui.control.Image
        Button2           matlab.ui.control.Button
        Button_E4         matlab.ui.control.Button
        Button_B3         matlab.ui.control.Button
        Button_G3         matlab.ui.control.Button
        Button_E2         matlab.ui.control.Button
        Button_A2         matlab.ui.control.Button
        Button_D3         matlab.ui.control.Button
        Tab2              matlab.ui.container.Tab
        RightPanel        matlab.ui.container.Panel
        EditField_2       matlab.ui.control.NumericEditField
        EditField_2Label  matlab.ui.control.Label
        UIAxes2           matlab.ui.control.UIAxes
        UIAxes            matlab.ui.control.UIAxes
        EditFieldLabe_Frq matlab.ui.control.Label
        EditField_Frq     matlab.ui.control.NumericEditField
        FrequencyEstimateEditFieldLabel_2 matlab.ui.control.Label
        EditField_guage   matlab.ui.control.EditField
        EditField2       matlab.ui.control.EditField
        EditField2Label  matlab.ui.control.Label


    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {480, 480};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {278, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end

        function plotButtonPushed(app,event)
            recorder = audiorecorder(96000, 24, 1);
            disp('Start speaking.')
            recorder.record(3);
            
            while recorder.isrecording()
                    pause(0.1);
                    %disp(recorder.getaudiodata())
                    plot(app.UIAxes,recorder.getaudiodata());
                    X1=abs(fft(recorder.getaudiodata()));
                    %plot(ax2,X1);
            
                    drawnow();
            end
            audiowrite('XYZ.wav', recorder.getaudiodata(), 96000)
            play(recorder);
         
            X1=abs(fft(recorder.getaudiodata()));
            disp(X1);
            disp('End of Recording.');
        
            %Get the audio file 
            [y,Fs] = audioread('XYZ.wav');  %y = samples, Fs = sample rate
            sound(y,Fs); %Listen to audio file
            %Get time of the signal and plot the signal
            samples = length(y);
            x = samples/Fs;    
            t = linspace(0, x, samples);
            %subplot(2,1,1),plot(t,y), ylabel('Amplitude'), xlabel('Time (secs)');
            %Converting signal to frequency estimate
                %Plot the frequency spectrum
                %pwelch = power spectral density estimate = (x, window, ...
                % noverlap, f1, fs)
            f1 = 0:(Fs/samples):(Fs/2-(Fs/samples));    %find the frequencies of the signal
            [Pxx, f] = pwelch(y, gausswin(Fs), Fs/2, f1/4, Fs);
            %subplot(2,1,2), plot(f,Pxx), ylabel('PSD'), xlabel('Frequency (Hz)');
                %Get the frequency estimate (spectral peak)
            [~, loc] = max(Pxx);
            freq_est = f(loc);
            %title(['Frequency Estimate = ', num2str(freq_est), 'Hz']);
        
            plot(app.UIAxes2,f,Pxx);
            app.EditField_Frq.Value = freq_est ;
            disp(freq_est);
            app.Gauge.Limits = [0 1000];
            app.Gauge.Value = freq_est;
            app.EditField_chord_guage.Value = "D3";
        end

        function ButtonA2(app, event)
            global freq_est;
            plot(app, event);
            app.Gauge.Limits = [106.8 113.2];
            app.Gauge.MajorTicks = [106.8 108.5 110 111.6 113.2];
            app.Gauge.MajorTickLabels = {'106.8', '108.4', '110.0', '111.6', '113.2'};
            app.Gauge.MinorTicks = [106.8 106.9 107 107.1 107.2 107.3 107.4 107.5 107.6 107.7 107.8 107.9 108 108.1 108.2 108.3 108.4 108.5 108.6 108.7 108.8 108.9 109 109.1 109.2 109.3 109.4 109.5 109.6 109.7 109.8 109.9 110 110.1 110.2 110.3 110.4 110.5 110.6 110.7 110.8 110.9 111 111.1 111.2 111.3 111.4 111.5 111.6 111.7 111.8 111.9 112 112.1 112.2 112.3 112.4 112.5 112.6 112.7 112.8 112.9 113 113.1 113.2];
            
            app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
            app.EditField_chord_guage.Value = "A2";
            app.Gauge.Value = freq_est;

        end

        function ImportButtonPushed(app, event)
            global freq_est;
            [filename, pathname]=uigetfile({'*.wav'},'File Selector');
            app.EditField2.Value=filename;
            selectfile = fullfile(pathname, filename);
            [y, Fs] = audioread(selectfile);
            %Graph1
            t = linspace(0,length(y)/Fs,length(y));
            plot(app.UIAxes,t,y);
            %Graph2
            samples = length(y);
            x = samples/Fs;    
            t = linspace(0, x, samples);
            f1 = 0:(Fs/samples):(Fs/2-(Fs/samples));    %find the frequencies of the signal
            [Pxx, f] = pwelch(y, gausswin(Fs), Fs/2, f1/4, Fs);
            [~, loc] = max(Pxx);
            freq_est = f(loc);
            app.EditField_Frq.Value = freq_est;
            disp(freq_est);
        
            plot(app.UIAxes2,f,Pxx);
            app.EditField_Frq.Value = freq_est ;

            if app.EditField_Frq.Value < 82.41
                app.Gauge3.MajorTicks = [0 10 20 30 40 50 60 70 80 90 100];
                app.Gauge3.MajorTickLabels = {'0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'};
                app.Gauge3.MinorTicks = [0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 66 68 70 72 74 76 78 80 82 84 86 88 90 92 94 96 98 100];
                app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
            end

            if app.EditField_Frq.Value >= 82.41 , app.EditField_Frq.Value < 110
                app.Gauge.Limits = [80.06 84.82];
                app.Gauge.MajorTicks = [80.06 81.23 82.41 83.61 84.82];
                app.Gauge.MajorTickLabels = {'80.06', '81.23', '82.41', '83.61', '84.82'};
                app.Gauge.MinorTicks = [80.06,80.1575,80.255,80.3525,80.45,80.5475,80.645,80.7425,80.84,80.9375,81.035,81.13250000000001,81.23,81.3275,81.425,81.52250000000001,81.62,81.7175,81.815,81.91250000000001,82.01,82.1075,82.205,82.30250000000001,82.4,82.4975,82.595,82.6925,82.79,82.8875,82.985,83.0825,83.18,83.2775,83.375,83.4725,83.57000000000001,83.6675,83.765,83.8625,83.96000000000001,84.0575,84.155,84.2525,84.35000000000001,84.4475,84.545,84.6425,84.74000000000001,84.82];
                app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
                app.EditField_chord_guage.Value = "E2";
                app.Gauge.Value = freq_est;
            end

            if app.EditField_Frq.Value >= 110 , app.EditField_Frq.Value < 146.8
                app.Gauge.Limits = [106.8 113.2];
                app.Gauge.MajorTicks = [106.8 108.5 110 111.6 113.2];
                app.Gauge.MajorTickLabels = {'106.8', '108.4', '110.0', '111.6', '113.2'};
                app.Gauge.MinorTicks = [106.8 106.9 107 107.1 107.2 107.3 107.4 107.5 107.6 107.7 107.8 107.9 108 108.1 108.2 108.3 108.4 108.5 108.6 108.7 108.8 108.9 109 109.1 109.2 109.3 109.4 109.5 109.6 109.7 109.8 109.9 110 110.1 110.2 110.3 110.4 110.5 110.6 110.7 110.8 110.9 111 111.1 111.2 111.3 111.4 111.5 111.6 111.7 111.8 111.9 112 112.1 112.2 112.3 112.4 112.5 112.6 112.7 112.8 112.9 113 113.1 113.2];
                
                app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
                app.EditField_chord_guage.Value = "A2";
                app.Gauge.Value = freq_est;
            end

            if app.EditField_Frq.Value >= 146.8 , app.EditField_Frq.Value < 196
                app.Gauge.Limits = [142.7 151.1];
                app.Gauge.MajorTicks = [142.7 144.7 146.8 149 151.1];
                app.Gauge.MajorTickLabels = {'142.7', '144.7', '146.8', '149.0', '151.1'};
                app.Gauge.MinorTicks = [142.7,142.79999999999998,142.89999999999998,143,143.1,143.2,143.29999999999998,143.39999999999998,143.5,143.6,143.7,143.79999999999998,143.89999999999998,144,144.1,144.2,144.29999999999998,144.39999999999998,144.5,144.6,144.7,144.79999999999998,144.89999999999998,145,145.1,145.2,145.29999999999998,145.39999999999998,145.5,145.6,145.7,145.79999999999998,145.89999999999998,146,146.1,146.2,146.29999999999998,146.39999999999998,146.5,146.6,146.7,146.79999999999998,146.89999999999998,147,147.1,147.2,147.29999999999998,147.39999999999998,147.5,147.6,147.7,147.79999999999998,147.89999999999998,148,148.1,148.2,148.29999999999998,148.39999999999998,148.5,148.6,148.7,148.79999999999998,148.89999999999998,149,149.1,149.2,149.29999999999998,149.39999999999998,149.5,149.6,149.7,149.79999999999998,149.89999999999998,150,150.1,150.2,150.29999999999998,150.39999999999998,150.5,150.6,150.7,150.79999999999998,150.89999999999998,151,151.1];
                app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
                app.EditField_chord_guage.Value = "D3";
                app.Gauge.Value = freq_est;
            end

            if app.EditField_Frq.Value >= 196 , app.EditField_Frq.Value < 246.9
                app.Gauge.Limits = [190.4 201.7];
                app.Gauge.MajorTicks = [190.4 193.2 196 198.8 201.7];
                app.Gauge.MajorTickLabels = {'190.4', '193.2', '196', '198.8', '201.7'};
                app.Gauge.MinorTicks = [190.4 190.6 190.8 191 191.2 191.4 191.6 191.8 192 192.2 192.4 192.6 192.8 193 193.2 193.4 193.6 193.8 194 194.2 194.4 194.6 194.8 195 195.2 195.4 195.6 195.8 196 196.2 196.4 196.6 196.8 197 197.2 197.4 197.6 197.8 198 198.2 198.4 198.6 198.8 199 199.2 199.4 199.6 199.8 200 200.2 200.4 200.6 200.8 201 201.2 201.4 201.7];
                app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
                app.EditField_chord_guage.Value = "G3";
                app.Gauge.Value = freq_est;
            end

            if app.EditField_Frq.Value >= 246.9 , app.EditField_Frq.Value < 329.6
                app.Gauge.Limits = [239.9 254.2];
                app.Gauge.MajorTicks = [239.9 243.4 246.9 250.5 254.2];
                app.Gauge.MajorTickLabels = {'239.9', '243.4', '246.9', '250.5', '254.2'};
                app.Gauge.MinorTicks = [239.9 240.09 240.28 240.47 240.66 240.85 241.04 241.23 241.42 241.61 241.8 241.99 242.18 242.37 242.56 242.75 242.94 243.13 243.32 243.51 243.7 243.89 244.08 244.27 244.46 244.65 244.84 245.03 245.22 245.41 245.6 245.79 245.98 246.17 246.36 246.55 246.74 246.93 247.12 247.31 247.5 247.69 247.88 248.07 248.26 248.45 248.64 248.83 249.02 249.21 249.4 249.59 249.78 249.97 250.16 250.35 250.54 250.73 250.92 251.11 251.3 251.49 251.68 251.87 252.06 252.25 252.44 252.63 252.82 253.01 253.2 253.39 253.58 253.77 253.96 254.2];
                app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
                app.EditField_chord_guage.Value = "B3";
                app.Gauge.Value = freq_est;
            end

           if app.EditField_Frq.Value >= 329.6 , app.EditField_Frq.Value < 349.6
                app.Gauge.Limits = [320.2 339.3];
                app.Gauge.MajorTicks = [320.2 324.9 329.6 334.4 339.3];
                app.Gauge.MajorTickLabels = {'320.2', '324.9', '329.6', '334.4', '339.3'};
                app.Gauge.MinorTicks = [320.2 320.49 320.78 321.07 321.36 321.65 321.94 322.23 322.52 322.81 323.1 323.39 323.68 323.97 324.26 324.55 324.84 325.13 325.42 325.71 326 326.29 326.58 326.87 327.16 327.45 327.74 328.03 328.32 328.61 328.9 329.19 329.48 329.77 330.06 330.35 330.64 330.93 331.22 331.51 331.8 332.09 332.38 332.67 332.96 333.25 333.54 333.83 334.12 334.41 334.7 334.99 335.28 335.57 335.86 336.15 336.44 336.73 337.02 337.31 337.6 337.89 338.18 338.47 338.76 339.05 339.3];
                app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
                app.EditField_chord_guage.Value = "E4";
                app.Gauge.Value = freq_est;
           end

           if app.EditField_Frq.Value > 349.6
                app.Gauge.Limits = [0 1000];
                app.Gauge.MajorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
                app.Gauge.MajorTickLabels = {'0', '100', '200', '300', '400', '500', '600', '700', '800', '900', '1000'};
                app.Gauge.MinorTicks = [0 20 40 60 80 100 120 140 160 180 200 220 240 260 280 300 320 340 360 380 400 420 440 460 480 500 520 540 560 580 600 620 640 660 680 700 720 740 760 780 800 820 840 860 880 900 920 940 960 980 1000];
                app.EditField_chord_guage.Value = "NON";
            end

        end


        function ButtonD3(app, event)
            global freq_est;
            plot(app, event);
            app.Gauge.Limits = [142.7 151.1];
            app.Gauge.MajorTicks = [142.7 144.7 146.8 149 151.1];
            app.Gauge.MajorTickLabels = {'142.7', '144.7', '146.8', '149.0', '151.1'};
            app.Gauge.MinorTicks = [142.7,142.79999999999998,142.89999999999998,143,143.1,143.2,143.29999999999998,143.39999999999998,143.5,143.6,143.7,143.79999999999998,143.89999999999998,144,144.1,144.2,144.29999999999998,144.39999999999998,144.5,144.6,144.7,144.79999999999998,144.89999999999998,145,145.1,145.2,145.29999999999998,145.39999999999998,145.5,145.6,145.7,145.79999999999998,145.89999999999998,146,146.1,146.2,146.29999999999998,146.39999999999998,146.5,146.6,146.7,146.79999999999998,146.89999999999998,147,147.1,147.2,147.29999999999998,147.39999999999998,147.5,147.6,147.7,147.79999999999998,147.89999999999998,148,148.1,148.2,148.29999999999998,148.39999999999998,148.5,148.6,148.7,148.79999999999998,148.89999999999998,149,149.1,149.2,149.29999999999998,149.39999999999998,149.5,149.6,149.7,149.79999999999998,149.89999999999998,150,150.1,150.2,150.29999999999998,150.39999999999998,150.5,150.6,150.7,150.79999999999998,150.89999999999998,151,151.1];
            app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
            app.EditField_chord_guage.Value = "D3";
            app.Gauge.Value = freq_est;

        end

        function ButtonE2(app, event)
            global freq_est;
            plot(app, event);
            app.Gauge.Limits = [80.06 84.82];
            app.Gauge.MajorTicks = [80.06 81.23 82.41 83.61 84.82];
            app.Gauge.MajorTickLabels = {'80.06', '81.23', '82.41', '83.61', '84.82'};
            app.Gauge.MinorTicks = [80.06,80.1575,80.255,80.3525,80.45,80.5475,80.645,80.7425,80.84,80.9375,81.035,81.13250000000001,81.23,81.3275,81.425,81.52250000000001,81.62,81.7175,81.815,81.91250000000001,82.01,82.1075,82.205,82.30250000000001,82.4,82.4975,82.595,82.6925,82.79,82.8875,82.985,83.0825,83.18,83.2775,83.375,83.4725,83.57000000000001,83.6675,83.765,83.8625,83.96000000000001,84.0575,84.155,84.2525,84.35000000000001,84.4475,84.545,84.6425,84.74000000000001,84.82];
            app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
            app.EditField_chord_guage.Value = "E2";
            app.Gauge.Value = freq_est;

        end

        function ButtonG3(app, event)
            global freq_est;
            plot(app, event);
            app.Gauge.Limits = [190.4 201.7];
            app.Gauge.MajorTicks = [190.4 193.2 196 198.8 201.7];
            app.Gauge.MajorTickLabels = {'190.4', '193.2', '196', '198.8', '201.7'};
            app.Gauge.MinorTicks = [190.4 190.6 190.8 191 191.2 191.4 191.6 191.8 192 192.2 192.4 192.6 192.8 193 193.2 193.4 193.6 193.8 194 194.2 194.4 194.6 194.8 195 195.2 195.4 195.6 195.8 196 196.2 196.4 196.6 196.8 197 197.2 197.4 197.6 197.8 198 198.2 198.4 198.6 198.8 199 199.2 199.4 199.6 199.8 200 200.2 200.4 200.6 200.8 201 201.2 201.4 201.7];
            app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
            app.EditField_chord_guage.Value = "G3";
            app.Gauge.Value = freq_est;

        end
        
        function ButtonB3(app, event)
            global freq_est;
            plot(app, event);
            app.Gauge.Limits = [239.9 254.2];
            app.Gauge.MajorTicks = [239.9 243.4 246.9 250.5 254.2];
            app.Gauge.MajorTickLabels = {'239.9', '243.4', '246.9', '250.5', '254.2'};
            app.Gauge.MinorTicks = [239.9 240.09 240.28 240.47 240.66 240.85 241.04 241.23 241.42 241.61 241.8 241.99 242.18 242.37 242.56 242.75 242.94 243.13 243.32 243.51 243.7 243.89 244.08 244.27 244.46 244.65 244.84 245.03 245.22 245.41 245.6 245.79 245.98 246.17 246.36 246.55 246.74 246.93 247.12 247.31 247.5 247.69 247.88 248.07 248.26 248.45 248.64 248.83 249.02 249.21 249.4 249.59 249.78 249.97 250.16 250.35 250.54 250.73 250.92 251.11 251.3 251.49 251.68 251.87 252.06 252.25 252.44 252.63 252.82 253.01 253.2 253.39 253.58 253.77 253.96 254.2];
            app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
            app.EditField_chord_guage.Value = "B3";
            app.Gauge.Value = freq_est;

        end

        function ButtonE4(app, event)
            global freq_est;
            plot(app, event);
            app.Gauge.Limits = [320.2 339.3];
            app.Gauge.MajorTicks = [320.2 324.9 329.6 334.4 339.3];
            app.Gauge.MajorTickLabels = {'320.2', '324.9', '329.6', '334.4', '339.3'};
            app.Gauge.MinorTicks = [320.2 320.49 320.78 321.07 321.36 321.65 321.94 322.23 322.52 322.81 323.1 323.39 323.68 323.97 324.26 324.55 324.84 325.13 325.42 325.71 326 326.29 326.58 326.87 327.16 327.45 327.74 328.03 328.32 328.61 328.9 329.19 329.48 329.77 330.06 330.35 330.64 330.93 331.22 331.51 331.8 332.09 332.38 332.67 332.96 333.25 333.54 333.83 334.12 334.41 334.7 334.99 335.28 335.57 335.86 336.15 336.44 336.73 337.02 337.31 337.6 337.89 338.18 338.47 338.76 339.05 339.3];
            app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
            app.EditField_chord_guage.Value = "E4";
            app.Gauge.Value = freq_est;

        end

        function plot(app, event)
            recorder = audiorecorder(96000, 24, 1);
            disp('Start speaking.')
            recorder.record(3);
        
            while recorder.isrecording()
                    pause(0.1);
                    %disp(recorder.getaudiodata())
                    plot(app.UIAxes,recorder.getaudiodata());
                    X1=abs(fft(recorder.getaudiodata()));
                    %plot(ax2,X1);
            
                    drawnow();
            end
            audiowrite('XYZ.wav', recorder.getaudiodata(), 96000)
            play(recorder);
         
            X1=abs(fft(recorder.getaudiodata()));
            %disp(X1);
            disp('End of Recording.');
        
            %Get the audio file 
            [y,Fs] = audioread('XYZ.wav');  %y = samples, Fs = sample rate
            sound(y,Fs); %Listen to audio file
            %Get time of the signal and plot the signal
            samples = length(y);
            x = samples/Fs;    
            t = linspace(0, x, samples);
            %subplot(2,1,1),plot(t,y), ylabel('Amplitude'), xlabel('Time (secs)');
            %Converting signal to frequency estimate
                %Plot the frequency spectrum
                %pwelch = power spectral density estimate = (x, window, ...
                % noverlap, f1, fs)
            f1 = 0:(Fs/samples):(Fs/2-(Fs/samples));    %find the frequencies of the signal
            [Pxx, f] = pwelch(y, gausswin(Fs), Fs/2, f1/4, Fs);
            %subplot(2,1,2), plot(f,Pxx), ylabel('PSD'), xlabel('Frequency (Hz)');
                %Get the frequency estimate (spectral peak)
            [~, loc] = max(Pxx);
            global freq_est;
            freq_est = f(loc)/2;
            %title(['Frequency Estimate = ', num2str(freq_est), 'Hz']);
        
            plot(app.UIAxes2,f,Pxx);
            app.EditField_Frq.Value = freq_est ;
        
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0 1 0];
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'Guitar Tuner';

            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);
            
            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {278, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.ForegroundColor = [0.6392 0.8824 0.8627];
            app.LeftPanel.BackgroundColor = [0.6392 0.8824 0.8627];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.LeftPanel);
            app.TabGroup.Position = [7 1 263 237];

            % Create Tab
            app.Tab = uitab(app.TabGroup);
            app.Tab.Title = 'Basic';
            app.Tab.BackgroundColor = [0.9294 0.9176 0.898];

            % Create Image
            app.Image = uiimage(app.Tab);
            app.Image.ScaleMethod = 'stretch';
            app.Image.Position = [32 -71 205 278];
            app.Image.ImageSource = 'guitar.png';

            % Create Button_D3
            app.Button_D3 = uibutton(app.Tab, 'push');
            app.Button_D3.ButtonPushedFcn = createCallbackFcn(app, @ButtonD3, true);
            app.Button_D3.BackgroundColor = [0.9882 0.7255 0.6627];
            app.Button_D3.Text = 'D3';
            app.Button_D3.Position = [21 140 55 55];
            app.Button_D3.FontWeight = 'bold';

            % Create Button_A2
            app.Button_A2 = uibutton(app.Tab, 'push');
            app.Button_A2.BackgroundColor = [1 0.8588 0.7961];
            app.Button_A2.Position = [21 81 55 55];
            app.Button_A2.Text = 'A2';
            app.Button_A2.ButtonPushedFcn = createCallbackFcn(app, @ButtonA2, true);
            app.Button_A2.FontWeight = 'bold';

            % Create Button_E2
            app.Button_E2 = uibutton(app.Tab, 'push');
            app.Button_E2.BackgroundColor = [0.9882 0.7255 0.6627];
            app.Button_E2.Position = [22 20 55 55];
            app.Button_E2.Text = 'E2';
            app.Button_E2.ButtonPushedFcn = createCallbackFcn(app, @ButtonE2, true);
            app.Button_E2.FontWeight = 'bold';

            % Create Button_G3
            app.Button_G3 = uibutton(app.Tab, 'push');
            app.Button_G3.BackgroundColor = [1 0.8588 0.7961];
            app.Button_G3.Position = [192 139 55 55];
            app.Button_G3.Text = 'G3';
            app.Button_G3.ButtonPushedFcn = createCallbackFcn(app, @ButtonG3, true);
            app.Button_G3.FontWeight = 'bold';

            % Create Button_B3
            app.Button_B3 = uibutton(app.Tab, 'push');
            app.Button_B3.BackgroundColor = [0.9882 0.7255 0.6627];
            app.Button_B3.Position = [192 81 55 55];
            app.Button_B3.Text = 'B3';
            app.Button_B3.ButtonPushedFcn = createCallbackFcn(app, @ButtonB3, true);
            app.Button_B3.FontWeight = 'bold';

            % Create Button_E4
            app.Button_E4 = uibutton(app.Tab, 'push');
            app.Button_E4.BackgroundColor = [1 0.8588 0.7961];
            app.Button_E4.Position = [192 20 55 55];
            app.Button_E4.Text = 'E4';
            app.Button_E4.ButtonPushedFcn = createCallbackFcn(app, @ButtonE4, true);
            app.Button_E4.FontWeight = 'bold';

            % Create Tab2
            app.Tab2 = uitab(app.TabGroup);
            app.Tab2.Title = 'Import';
            app.Tab2.BackgroundColor = [0.9294 0.9176 0.898];

            % Create Button2
            app.Button2 = uibutton(app.Tab2, 'push');
            app.Button2.Position = [148 153 100 23];
            app.Button2.Text = 'Import';
            app.Button2.ButtonPushedFcn = createCallbackFcn(app, @ImportButtonPushed, true);
            app.Button2.BackgroundColor = [0.9882 0.7255 0.6627];
            app.Button2.FontWeight = 'bold';

            % Create EditField2Label
            app.EditField2Label = uilabel(app.Tab2);
            app.EditField2Label.HorizontalAlignment = 'right';
            app.EditField2Label.Position = [9 153 62 22];
            app.EditField2Label.Text = 'File Name';
            app.EditField2Label.FontWeight = 'bold';

            % Create EditField2
            app.EditField2 = uieditfield(app.Tab2, 'text');
            app.EditField2.Position = [76 153 65 22];
            

            % Create GaugeLabel
            app.GaugeLabel = uilabel(app.LeftPanel);
            app.GaugeLabel.HorizontalAlignment = 'center';
            app.GaugeLabel.Position = [117 266 41 22];

            % Create Gauge
            app.Gauge = uigauge(app.LeftPanel, 'semicircular');
            app.Gauge.Position = [3 303 269 145];
            app.Gauge.ScaleColors = [1 0 0;1 1 0;0 1 0;1 1 0;1 0 0];
            app.Gauge.BackgroundColor = [0.9294 0.9176 0.898];


            % Create EditField_chord_guage
            app.EditField_chord_guage = uieditfield(app.LeftPanel, 'text');
            app.EditField_chord_guage.Position = [123 350 37 20];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            app.RightPanel.ForegroundColor = [0.6392 0.8824 0.8627];
            app.RightPanel.BackgroundColor = [0.6392 0.8824 0.8627];

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, 'Time (secs)')
            ylabel(app.UIAxes, 'Amplitude')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [31 266 300 185];
            app.UIAxes.Color = [0.9294 0.9176 0.898];
            app.UIAxes.Box = 'on';
            app.UIAxes.ColorOrder = [1 0.411764705882353 0.16078431372549;0.850980392156863 0.325490196078431 0.0980392156862745;0.929411764705882 0.694117647058824 0.125490196078431;0.494117647058824 0.184313725490196 0.556862745098039;0.466666666666667 0.674509803921569 0.188235294117647;0.301960784313725 0.745098039215686 0.933333333333333;0.635294117647059 0.0784313725490196 0.184313725490196];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.RightPanel);
            title(app.UIAxes2, '')
            xlabel(app.UIAxes2, 'Frequency (Hz)')
            ylabel(app.UIAxes2, 'PSD')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [31 29 300 185];
            app.UIAxes2.Color = [0.9294 0.9176 0.898];
            app.UIAxes2.Box = 'on';
            app.UIAxes2.MinorGridColor = [0.7608 0.4118 0.3294];
            app.UIAxes2.ColorOrder = [1 0.411764705882353 0.16078431372549;0.850980392156863 0.325490196078431 0.0980392156862745;0.929411764705882 0.694117647058824 0.125490196078431;0.494117647058824 0.184313725490196 0.556862745098039;0.466666666666667 0.674509803921569 0.188235294117647;0.301960784313725 0.745098039215686 0.933333333333333;0.635294117647059 0.0784313725490196 0.184313725490196];



            % Create EditFieldLabel
            app.EditFieldLabe_Frq = uilabel(app.UIFigure);
            app.EditFieldLabe_Frq.HorizontalAlignment = 'right';
            app.EditFieldLabe_Frq.Position = [330 230 150 22];
            app.EditFieldLabe_Frq.Text = 'Frequency Estimate';
            app.EditFieldLabe_Frq.FontWeight = 'bold';
            

            % Create EditField
            app.EditField_Frq = uieditfield(app.UIFigure, 'numeric');
            app.EditField_Frq.ValueChangedFcn = createCallbackFcn(app, @plotButtonPushed, true);
            app.EditField_Frq.Editable = 'off';
            app.EditField_Frq.Position = [500 230 79 22];

            % Create FrequencyEstimateEditFieldLabel_2
            app.FrequencyEstimateEditFieldLabel_2 = uilabel(app.UIFigure);
            app.FrequencyEstimateEditFieldLabel_2.HorizontalAlignment = 'right';
            app.FrequencyEstimateEditFieldLabel_2.Position = [574 230 31 22];
            app.FrequencyEstimateEditFieldLabel_2.Text = 'HZ';
            app.FrequencyEstimateEditFieldLabel_2.FontWeight = 'bold';


            

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Tuner

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

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