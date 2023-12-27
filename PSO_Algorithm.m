%Graph size
xlim = [-10, 10];
ylim = [-10, 10];

% Target points
target_position = rand(1, 2) * (xlim(2) - xlim(1)) + xlim(1);

% Particles
num_particles = 5;
particles = struct('position', cell(1, num_particles), 'velocity', cell(1, num_particles), 'Pbest', cell(1, num_particles), 'angle', cell(1, num_particles));

% Timer
last_update_time = tic;

for i = 1:num_particles
    particles(i).position = rand(1, 2) * (xlim(2) - xlim(1)) + xlim(1);
    particles(i).velocity = rand(1, 2); % Initial velocity
    particles(i).Pbest = particles(i).position;
    particles(i).angle = 0; 
end

% Objective function
f = @(x) norm(x - target_position)^2; % Euclidean distance

% Learning parameters
c1 = 2; % Cognitive coefficient
c2 = 2; % Social coefficient
w = 0.9; % Inertia weight

% Max No. of iterations
max_iter = 200;

proximity_threshold = 2;
angle_increment = pi/30;

for iter = 1:max_iter

    % Gbestl best position update
    Gbestl_Pbest = particles(1).Pbest;
    for j = 1:num_particles
        if f(particles(j).position) < f(Gbestl_Pbest)
            Gbestl_Pbest = particles(j).position;
        end
    end

    % random number genaration between 0 and 1
    rand_num = rand();

    
    if toc(last_update_time) > 8 % Time lapse
        if rand_num < 0.5
            target_position = []; 
        else
            target_position = rand(1, 2) * (xlim(2) - xlim(1)) + xlim(1);
            f = @(x) norm(x - target_position)^2; % Objective functionupdate
            % Gbest reconfig
            for j = 1:num_particles
                if f(particles(j).position) < f(Gbestl_Pbest)
                    Gbestl_Pbest = particles(j).position;
                end
            end
        end
        last_update_time = tic; % timer reset
    end

    %velocities and positions update
    for j = 1:num_particles
        if ~isempty(target_position) && norm(particles(j).position - target_position) < proximity_threshold
            particles(j).angle = particles(j).angle + angle_increment;

            %new position in circular motion
            new_position = target_position + proximity_threshold * [cos(particles(j).angle), sin(particles(j).angle)];
            particles(j).velocity = new_position - particles(j).position;
            particles(j).position = new_position;
        else
            %PSO velocity
            new_velocity = w * particles(j).velocity + ...
                c1 * rand() * (particles(j).Pbest - particles(j).position) + ...
                c2 * rand() * (Gbestl_Pbest - particles(j).position);

            %limit velocity magnitude
            if norm(new_velocity) > 1
                new_velocity = new_velocity / norm(new_velocity);
            end

            particles(j).velocity = new_velocity;

            
            particles(j).position = particles(j).position + particles(j).velocity;

            % Pbest position
            if f(particles(j).position) < f(particles(j).Pbest)
                particles(j).Pbest = particles(j).position;
            end
        end

        
        particles(j).position = max(min(particles(j).position, xlim(2)), xlim(1));
    end

    % Visualisation of particle&location
    clf; % Clear the figure
    hold on;
    for j = 1:num_particles
        plot(particles(j).position(1), particles(j).position(2), 'o', 'MarkerSize', 5);
    end
    if ~isempty(target_position)
        plot(target_position(1), target_position(2), 'x', 'MarkerSize', 10, 'Color', 'r');
    end
    axis([xlim ylim]);
    hold off;
    pause(0.05);
end
