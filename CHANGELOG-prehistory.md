## Prehistory

- [Changing Serialization/Serializers namespace to `Serializable` (November 30, 2011)](https://github.com/rails/rails/commit/8896b4fdc8a543157cdf4dfc378607ebf6c10ab0)
  - [Merge branch 'serializers'. This implements the ActiveModel::Serializer object. Includes code, tests, generators and guides. From José and Yehuda with love.](https://github.com/rails/rails/commit/fcacc6986ab60f1fb2e423a73bf47c7abd7b191d)
  - But [was reverted](https://github.com/rails/rails/commit/5b2eb64ceb08cd005dc06b721935de5853971473).
    '[Revert the serializers API as other alternatives are now also under discussion](https://github.com/rails/rails/commit/0a4035b12a6c59253cb60f9e3456513c6a6a9d33)'.
- [Proposed Implementation to Rails 3.2 by @wycats and @josevalim (November 25, 2011)](https://github.com/rails/rails/pull/3753)
  - [Creation of `ActionController::Serialization`, initial serializer
    support (September, 26 2011)](https://github.com/rails/rails/commit/8ff7693a8dc61f43fc4eaf72ed24d3b8699191fe).
  - [Docs and CHANGELOG](https://github.com/rails/rails/commit/696d01f7f4a8ed787924a41cce6df836cd73c46f)
  - [Deprecation of ActiveModel::Serialization to ActiveModel::Serializable](https://github.com/rails/rails/blob/696d01f7f4a8ed787924a41cce6df836cd73c46f/activemodel/lib/active_model/serialization.rb)
- [Creation of `ActiveModel::Serialization` from `ActiveModel::Serializer` in Rails (2009)](https://github.com/rails/rails/commit/c6bc8e662614be711f45a8d4b231d5f993b024a7#diff-d029b9768d8df0407a35804a468e3ae5)
- [Integration of `ActiveModel::Serializer` into `ActiveRecord::Serialization`](https://github.com/rails/rails/commit/783db25e0c640c1588732967a87d65c10fddc08e)
- [Creation of `ActiveModel::Serializer` in Rails (2009)](https://github.com/rails/rails/commit/d2b78b3594b9cc9870e6a6ebfeb2e56d00e6ddb8#diff-80d5beeced9bdc24ca2b04a201543bdd)
- [Creation of `ActiveModel::Serializers::JSON` in Rails (2009)](https://github.com/rails/rails/commit/fbdf706fffbfb17731a1f459203d242414ef5086)
