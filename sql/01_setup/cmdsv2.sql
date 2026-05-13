UPDATE public.roads r
SET target = v.id
FROM public.roads_vertices v
WHERE ST_Equals(ST_EndPoint(r.geom), v.geom);