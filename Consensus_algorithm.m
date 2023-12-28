% Defining the Size of the graph
X = [-10, 10];
Y = [-10, 10];

% Location of the 3 locations (A,B,C) on the graph
locations = [6, -5; 0, 7; -5, -5];

% Parameters
numParticles = 5;
numLocations = 3;
maxIterations = 100; % how many before the run comes to and end
vShapeFormationSpacing = 1;
lineFormationSpacing = 1;
formationChangeThreshold = 0.5;
approachDistance = 0.25;
movementSpeed = 0.5; % Responsible for the speed of the particles

% Location of master particle
leaderPosition = [0, 0];

% Dictating the V-formation and line formation
vOffsets = [0, 0; -1, -1; 1, -1; -2, -2; 2, -2];
lineOffsets = [0, 0; 0, -1; 0, -2; 0, -3; 0, -4];

% Current target formation
currentTargetIndex = 1;
currentFormation = 'V';

% Simulation loop
for iter = 1:maxIterations
    % Current target location
    currentTarget = locations(currentTargetIndex, :);

    % Master particle movement
    directionToTarget = (currentTarget - leaderPosition);
    normDirectionToTarget = norm(directionToTarget);
    if normDirectionToTarget > 0
        movementStep = min(movementSpeed, normDirectionToTarget);
        leaderPosition = leaderPosition + (directionToTarget / normDirectionToTarget) * movementStep;
    end

    % Rotating formation
    if normDirectionToTarget > 0
        angleToTarget = atan2(directionToTarget(2), directionToTarget(1));
        rotationMatrix = [cos(angleToTarget) -sin(angleToTarget); sin(angleToTarget) cos(angleToTarget)];
        if strcmp(currentFormation, 'V')
            rotatedVOffsets = (rotationMatrix * vOffsets')';
            particlePositions = leaderPosition + rotatedVOffsets;
        else % Line formation
            rotatedLineOffsets = (rotationMatrix * lineOffsets')';
            particlePositions = leaderPosition + rotatedLineOffsets;
        end
    end

    % Graph visualisation
    clf; 
    hold on;
    plot(locations(:, 1), locations(:, 2), 'x', 'MarkerSize', 10, 'Color', 'red'); % Target locations
    plot(particlePositions(:, 1), particlePositions(:, 2), 'o', 'MarkerSize', 4, 'Color', 'blue'); % Particles
    axis([X Y]);
    title(sprintf('Iteration: %d', iter)); % Show current iteration
    hold off;
    pause(0.1);

    % Chwcking the dist to the current location
    if norm(leaderPosition - currentTarget) < formationChangeThreshold
        currentFormation = 'Line';
    elseif norm(leaderPosition - currentTarget) > formationChangeThreshold
        currentFormation = 'V';
    end

    % If target location is met
    if norm(leaderPosition - currentTarget) < approachDistance
        currentTargetIndex = mod(currentTargetIndex, numLocations) + 1;
        currentFormation = 'Line';
    end
end
