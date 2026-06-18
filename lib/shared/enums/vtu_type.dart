enum VtuType {
  airtime,
  data,
  electricity,
  cable;

  String get displayName => switch (this) {
        VtuType.airtime => 'Airtime',
        VtuType.data => 'Data',
        VtuType.electricity => 'Electricity',
        VtuType.cable => 'Cable TV',
      };

  String get apiEndpoint => switch (this) {
        VtuType.airtime => '/api/vtu/airtime',
        VtuType.data => '/api/vtu/data',
        VtuType.electricity => '/api/vtu/electricity',
        VtuType.cable => '/api/vtu/cable',
      };
}
