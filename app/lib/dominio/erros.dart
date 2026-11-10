/// Falhas previstas do SonoLeve. As telas exibem [mensagem] diretamente,
/// por isso ela é sempre escrita para o usuário final, em tom calmo.
abstract class FalhaSonoLeve implements Exception {
  const FalhaSonoLeve(this.mensagem);

  final String mensagem;

  @override
  String toString() => '$runtimeType: $mensagem';
}

/// Uma regra de negócio foi violada (RN01–RN09).
class RegraNegocioException extends FalhaSonoLeve {
  const RegraNegocioException(super.mensagem);
}

/// Sem internet para uma operação que precisa dela (item a.iv do projeto).
class FalhaConexaoException extends FalhaSonoLeve {
  const FalhaConexaoException([
    super.mensagem =
        'Sem conexão no momento. Tente de novo quando estiver online.',
  ]);
}

/// Credenciais inválidas, e-mail já em uso, senha fraca...
class FalhaAutenticacaoException extends FalhaSonoLeve {
  const FalhaAutenticacaoException(super.mensagem);
}
