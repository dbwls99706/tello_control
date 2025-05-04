clc;
clear all;

% Tello 드론 객체 생성 및 이륙
my_tello = ryze();
cameraObj = camera(my_tello);
takeoff(my_tello);

% 색상 감지 및 드론 제어 함수
function controlDrone(cameraObj, my_tello)
    state = 'initial'; % 초기 상태 설정
    while true
        % 카메라로부터 이미지 캡처
        frame = snapshot(cameraObj);
        imshow(frame);
        % 이미지를 HSV로 변환
        hsvFrame = rgb2hsv(frame);
        
        % 빨간색, 초록색, 파란색의 HSV 범위 정의
        redMask = (hsvFrame(:,:,1) > 0.95 | hsvFrame(:,:,1) < 0.05) & ...
                  (hsvFrame(:,:,2) > 0.36) & (hsvFrame(:,:,3) > 0.36);
        greenMask = (hsvFrame(:,:,1) > 0.23 & hsvFrame(:,:,1) < 0.42) & ...
                    (hsvFrame(:,:,2) > 0.36) & (hsvFrame(:,:,3) > 0.26);
        blueMask = (hsvFrame(:,:,1) > 0.55 & hsvFrame(:,:,1) < 0.75) & ...
                   (hsvFrame(:,:,2) > 0.36) & (hsvFrame(:,:,3) > 0.36);
        
        % 색상 객체 찾기
        redDetected = any(redMask(:));
        greenDetected = any(greenMask(:));
        blueDetected = any(blueMask(:));
        
        switch state
            case 'initial'
                % 빨간색을 중앙에서 찾기
                if redDetected
                    disp('Red color detected. Moving up 0.2m...');
                    moveup(my_tello, 'Distance', 0.2);
                    state = 'red_detected';
                else
                    % 빨간색이 감지되지 않으면 오른쪽으로 0.2m 이동
                    disp('No red color detected. Moving right 0.2m...');
                    moveright(my_tello, 'Distance', 0.2);
                end
            case 'red_detected'
                % 초록색을 중앙에서 찾기
                if greenDetected
                    disp('Green color detected. Moving right 0.2m...');
                    moveright(my_tello, 'Distance', 0.2);
                    state = 'green_detected';
                else
                    % 초록색이 감지되지 않으면 계속 상승
                    disp('No green color detected. Moving up 0.2m...');
                    moveup(my_tello, 'Distance', 0.2);
                end
            case 'green_detected'
                % 파란색을 중앙에서 찾기
                if blueDetected
                    disp('Blue color detected. Landing...');
                    land(my_tello);
                    return; % 함수 종료
                else
                    % 파란색이 감지되지 않으면 계속 오른쪽으로 이동
                    disp('No blue color detected. Moving right 0.2m...');
                    moveright(my_tello, 'Distance', 0.2);
                end
        end
        pause(0.5); % 잠시 대기
    end
end

% 색상 감지 및 드론 제어 함수 호출
controlDrone(cameraObj, my_tello);

% 드론 착륙 후 리소스 정리
clear all;