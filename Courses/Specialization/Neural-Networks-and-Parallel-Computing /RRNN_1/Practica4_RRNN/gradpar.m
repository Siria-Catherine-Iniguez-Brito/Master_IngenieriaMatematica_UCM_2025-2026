function [sol, fop, tiempo, neval, sc, i, rhog, fevo] = gradpar(f, xit, nmax, prec, h, displ, compl)
    sc = 0;
    neval = 0;
    rhog = [];
    tic
    format long
    dim = length(xit);
    sol = xit;
    fop = f(xit, compl);
    fevo = fop;
    neval = neval + 1;

    if displ == 1
        disp(['It: 0 | f:' num2str(fop) ' | NE: ' num2str(neval) ' | N. grad: --- | Rho: --- | CT: 0'])
    end

    for i = 1:nmax
        grad = zeros(1, dim);
        
        % === BUCLE 1 PARALELIZADO (Cálculo del gradiente) ===
        parfor j = 1:dim
            xp = xit;
            xp(j) = xp(j) + h;
            xm = xit;
            xm(j) = xm(j) - h;
            grad(j) = (f(xp, compl) - f(xm, compl)) / (2 * h);
        end
        neval = neval + (2 * dim); 

        rho = [1e-4, 1e-3, 1e-2, 1e-1, 1, 10, 100, 1000];
        fac = zeros(1, length(rho));
        
        % === BUCLE 2 PARALELIZADO (Búsqueda de paso óptimo) ===
        parfor j = 1:length(rho)
            xor_p = xit - rho(j) * grad;
            fac(j) = f(xor_p, compl);
        end
        neval = neval + length(rho); 

        [fac, iop] = min(fac);
        xit = xit - rho(iop) * grad;

        if (fac >= fop)
            if displ == 1
                disp(['It: ' num2str(i) ' | f:' num2str(fop) ' | NE: ' num2str(neval) ' | N. grad:' num2str(norm(grad)) ' | Rho: ' num2str(rho(iop)) ' | CT: ' num2str(round(toc))])
                disp('Stopping Criterium: Cannot Improve Best Point')
                sc = 2;
            end
            break
        end

        fold = fop;
        fop = fac;
        sol = xit;
        rhog(i) = rho(iop);
        fevo(i) = fop;

        if abs(fop - fold) < prec
            if displ == 1
                disp(['It: ' num2str(i) ' | f:' num2str(fop) ' | NE: ' num2str(neval) ' | N. grad:' num2str(norm(grad)) ' | Rho: ' num2str(rho(iop)) ' | CT: ' num2str(round(toc))])
                disp('Stopping Criterium: Precision Evolution Reached')
                sc = 1;
            end
            break
        end

        if displ == 1
            disp(['It: ' num2str(i) ' | f:' num2str(fop) ' | NE: ' num2str(neval) ' | N. grad:' num2str(norm(grad)) ' | Rho: ' num2str(rho(iop)) ' | CT: ' num2str(round(toc))])
        end
    end

    if i >= nmax
        if displ == 1
            disp('Stopping Criterium: Maximum of Iteration Reached')
        end
        sc = 0;
    end
    tiempo = toc;
end