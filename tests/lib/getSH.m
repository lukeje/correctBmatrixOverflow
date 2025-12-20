function [Y,LB] = getSH (Lmax, dirs, CS_phase)

    % Ylm_n = get_even_SH(dirs,Lmax,CS_phase)
    %
    % if CS_phase=1, then the definition uses the Condon-Shortley phase factor
    % of (-1)^m. Default is CS_phase=0 (so this factor is omitted)
    %
    % By: Santiago Coelho (https://github.com/NYU-DiffusionMRI/SMI/blob/master/SMI.m)
    %
    % Luke Edwards: added computation of Laplace--Beltrami operator which can be used
    % for regularisation
    
    if size(dirs,2)~=3
        dirs=dirs';
    end
    Nmeas=size(dirs,1);
    [PHI,THETA]=cart2sph(dirs(:,1),dirs(:,2),dirs(:,3)); THETA=pi/2-THETA;
    l=0:2:Lmax;
    l_all=zeros(1,(l(end)/2+1).*(l(end)+1));
    m_all=zeros(1,(l(end)/2+1).*(l(end)+1));
    n_begin=1;
    for ii=1:length(l)
        n_end=n_begin+2*l(ii);
        l_all(n_begin:n_end)=l(ii);
        m_all(n_begin:n_end)=-l(ii):l(ii);
        n_begin=n_end+1;
    end
    K_lm=sqrt((2*l_all+1)./(4*pi) .* factorial(l_all-abs(m_all))./factorial(l_all+abs(m_all)));
    if nargin==2 || isempty(CS_phase) || ~exist('CS_phase','var') || ~CS_phase
        extra_factor=ones(size(K_lm));
        extra_factor(m_all~=0)=sqrt(2);
    else
        extra_factor=ones(size(K_lm));
        extra_factor(m_all~=0)=sqrt(2);
        extra_factor=extra_factor.*(-1).^(m_all);
    end
    P_l_in_cos_theta=zeros(length(l_all),Nmeas);
    phi_term=zeros(length(l_all),Nmeas);
    id_which_pl=zeros(1,length(l_all));
    for ii=1:length(l_all)
        all_Pls=legendre(l_all(ii),cos(THETA));
        P_l_in_cos_theta(ii,:)=all_Pls(abs(m_all(ii))+1,:);
        id_which_pl(ii)=abs(m_all(ii))+1;
        if m_all(ii)>0
            phi_term(ii,:)=cos(m_all(ii)*PHI);
        elseif m_all(ii)==0
            phi_term(ii,:)=1;
        elseif m_all(ii)<0
            phi_term(ii,:)=sin(-m_all(ii)*PHI);
        end
    end
    Y_lm=repmat(extra_factor',1,Nmeas).*repmat(K_lm',1,Nmeas).*phi_term.*P_l_in_cos_theta;
    Y=Y_lm';

    % Laplace--Beltrami operator
    if nargout>1
        LB=diag((l_all.*(l_all+1)).^2);
    end
end
