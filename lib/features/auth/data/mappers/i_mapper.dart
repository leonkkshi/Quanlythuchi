abstract class IMapper<M, E> {
  E toEntity(M model);
  M toModel(E entity);
}
