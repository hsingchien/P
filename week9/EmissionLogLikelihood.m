function pr = EmissionLogLikelihood(O, G, P, K)
    num_nodes = size(G,1);
    po = zeros(num_nodes,K);
    curr_G = G;
    for i = 1:K
        for j = 1:size(curr_G,1) %1:numNodes
            Or = O(j,:);
            if(curr_G(j,1) == 0) % root
                mu_x = P.clg(j).mu_x(i);
                mu_y = P.clg(j).mu_y(i);
                mu_ang = P.clg(j).mu_angle(i);
                sig_x = P.clg(j).sigma_x(i);
                sig_y = P.clg(j).sigma_y(i);
                sig_ang = P.clg(j).sigma_angle(i);
                po(j,i) = lognormpdf(Or(1),mu_y,sig_y) + lognormpdf(Or(2),mu_x,sig_x) + lognormpdf(Or(3),mu_ang,sig_ang);    
            else  
                cp = curr_G(j, 2);
                cpv = O(cp,:);
                cpv = [1,cpv];
                thetas = P.clg(j).theta(i,:);
                mu_y = sum(cpv.*(thetas(1:4)));
                mu_x = sum(cpv.*(thetas(5:8)));
                mu_angle = sum(cpv.*(thetas(9:end)));
                sig_y = P.clg(j).sigma_y(i);
                sig_x = P.clg(j).sigma_x(i);
                sig_angle = P.clg(j).sigma_angle(i);
                po(j,i) = lognormpdf(Or(1), mu_y, sig_y)+lognormpdf(Or(2), mu_x, sig_x)+lognormpdf(Or(3),mu_angle, sig_angle);
            end
        end
    end

pr = sum(po,1); %pr 1xK


end

