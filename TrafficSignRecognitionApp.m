classdef TrafficSignRecognitionApp < matlab.apps.AppBase

    % Properties
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        UIAxes                matlab.ui.control.UIAxes
        UploadButton          matlab.ui.control.Button
        RecognizeButton       matlab.ui.control.Button
        LabelResult           matlab.ui.control.Label
    end

    properties (Access = private)
        UploadedImage % Uploaded image data
        TrainedNet    % Trained CNN model
    end

    % Code that runs after component creation
    methods (Access = private)
        function startupFcn(app)
            % Load trained CNN from given file path
            try
                modelPath = 'C:\Users\namde\OneDrive\Desktop\Image_Processing\TRAINED_MODEL.mat';
                cnnModel = load(modelPath);  % Must contain variable named 'net'
                app.TrainedNet = cnnModel.net;
                disp('Trained model loaded successfully.');
            catch
                uialert(app.UIFigure, ...
                    'Error loading trained model. Ensure TRAINED_MODEL.mat is available at the specified path.', ...
                    'Model Load Error');
                app.TrainedNet = [];
                return;
            end
        end
    end

    % Upload image button
    methods (Access = private)
        function UploadButtonPushed(app, event)
            [file, path] = uigetfile({'.jpg;.png;*.jpeg'}, 'Select an Image');
            if isequal(file, 0)
                return;
            end
            fullImagePath = fullfile(path, file);
            app.UploadedImage = imread(fullImagePath);
            imshow(app.UploadedImage, 'Parent', app.UIAxes);
            app.LabelResult.Text = 'Image loaded. Ready to recognize.';
        end
    end

    % Recognize button
    methods (Access = private)
        function RecognizeButtonPushed(app, ~)
            if isempty(app.UploadedImage)
                uialert(app.UIFigure, 'Upload an image first.', 'No Image');
                return;
            end

            if isempty(app.TrainedNet)
                uialert(app.UIFigure, 'Trained model not loaded. Ensure TRAINED_MODEL.mat is available.', ...
                        'Model Missing');
                return;
            end

            resizedImg = imresize(app.UploadedImage, [32 32]); % Adjust size to match model input
            label = classify(app.TrainedNet, resizedImg);
            app.LabelResult.Text = ['Prediction: ', char(label)];
        end
    end

    % Component initialization
    methods (Access = private)
        function createComponents(app)
            % Create UIFigure and components
            app.UIFigure = uifigure('Name', 'Traffic Sign Recognition');

            app.UIAxes = uiaxes(app.UIFigure);
            app.UIAxes.Position = [20 120 300 300];
            title(app.UIAxes, 'Uploaded Image');
            xlabel(app.UIAxes, '');
            ylabel(app.UIAxes, '');
            app.UIAxes.Box = 'on';

            app.UploadButton = uibutton(app.UIFigure, 'push');
            app.UploadButton.Text = 'Upload Image';
            app.UploadButton.Position = [340 300 120 30];
            app.UploadButton.ButtonPushedFcn = createCallbackFcn(app, @UploadButtonPushed, true);

            app.RecognizeButton = uibutton(app.UIFigure, 'push');
            app.RecognizeButton.Text = 'Recognize Sign';
            app.RecognizeButton.Position = [340 250 120 30];
            app.RecognizeButton.ButtonPushedFcn = createCallbackFcn(app, @RecognizeButtonPushed, true);

            app.LabelResult = uilabel(app.UIFigure);
            app.LabelResult.Position = [20 60 440 30];
            app.LabelResult.FontSize = 14;
            app.LabelResult.Text = 'Upload an image to start.';
        end
    end

    methods (Access = public)
        function app = TrafficSignRecognitionApp
            % Create and configure components
            createComponents(app);

            % Register the app
            registerApp(app, app.UIFigure);

            % Run startup function
            runStartupFcn(app, @startupFcn);
        end

        function delete(app)
            % Delete UIFigure when app is deleted
            delete(app.UIFigure);
        end
    end
end
