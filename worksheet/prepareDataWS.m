filenames = {'armadillo.ply', 'bun_zipper_res2.ply', 'dragon_vrip_res2.ply'};
fileIndex = 2;
nface = 15000;
[vertex,face] = read_mesh(filenames{fileIndex});

if numel(face)/3 > nface
    [vertex,face] = perform_mesh_simplification(vertex,face,nface);
end

Mesh.v = vertex;
Mesh.f = face;
%%

kmzFiles = dir(fullfile('mesh/kmz', '*.kmz'));
for i = 5:numel(kmzFiles)
    Mesh = importKmz(kmzFiles(i).name)
    break
end


%%

displayMesh(Mesh);

%%
[Umin,Umax,Cmin,Cmax,Cmean,Cgauss,Normal] = compute_curvature(vertex,face);
%%
figure;
displayMeshSaliency(Mesh, Cmean);


%%


D = pdist2(vertex, vertex);

%%

plot_mesh(Mesh.v, Mesh.f);





%%

Curvature.v = Mesh.v;
Curvature.c = Cmean;

epsilon = 0.01 * sqrt(sum((min(Mesh.v)-max(Mesh.v)).^2));
scales = epsilon * (2:6);

%%
[weightedAverage] = computeWeightedAverage(Curvature, scales(3));

%%
figure
displayMeshSaliency(Mesh, weightedAverage);



%%

global weightedAverageCache;
weightedAverageCache = {};

%%
level = 3;
[levelSaliency] = centerSurround(Curvature, level, epsilon);
%%
max(levelSaliency)
std(levelSaliency)
%%
figure
levelSaliency = normalize(levelSaliency);


displayMeshSaliency(Mesh, levelSaliency);

%%
    global meshSaliencyPipelineCache;
    if ~isfield(meshSaliencyPipelineCache, 'D');
        meshSaliencyPipelineCache.D = pdist2(Mesh.v, Mesh.v);
    end
    D = meshSaliencyPipelineCache.D;
    
    if ~isfield(meshSaliencyPipelineCache, 'avgDist');
        D_ = D;
        D_(D==0) = Inf;
        meshSaliencyPipelineCache.avgMinDist = mean(min(D_,[],2));
    end
    avgMinDist = meshSaliencyPipelineCache.avgMinDist;

    windowSize = 10*avgMinDist;

    basis = repmat(levelSaliency, [size(basis, 1) 1]);
    basis(D > windowSize) = -Inf;
    
%%

[globalMax,globalMaxI] = max(levelSaliency);

[~,maxI] = max(basis,[],2);
sss=(maxI==(1:size(basis,1))');
sss(globalMaxI)=0;
sum(sss);

mean(Curvature.c(sss))


displayMeshSaliency(Mesh, levelSaliency);
% displayMesh(Mesh);
hold on;

drawPoint3d(Mesh.v(sss,:),'color','red','marker','.','markersize', 20)
drawPoint3d(Mesh.v(globalMaxI,:),'color','green','marker','.','markersize', 30)


%%

max(basis,[],2)
%%
aaa = basis;
aaa(basis~=-Inf) = 1;
aaa(basis==-Inf) = 0;
bbb=sum(aaa,2);
sss=(bbb==(1:size(bbb,1))');
sum(sss)

%%
% global meshSaliencyPipelineCache;
meshSaliencyPipelineCache = struct();



%%






