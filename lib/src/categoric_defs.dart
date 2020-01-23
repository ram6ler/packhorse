part of packhorse;

enum CategoricStatistic { numberOfInstances, impurity, entropy }

final _categoricStatisticGenerator =
    <CategoricStatistic, num Function(Categoric)>{
  CategoricStatistic.numberOfInstances: (x) => x.length,
  CategoricStatistic.impurity: (x) => x.impurity,
  CategoricStatistic.entropy: (x) => x.entropy
};
