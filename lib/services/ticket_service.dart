import '../core/utils/result.dart';
import '../models/ticket.dart';
import '../repositories/ticket_repository.dart';

class TicketService {
  final ITicketRepository _repository;
  TicketService({required ITicketRepository repository}) : _repository = repository;

  Future<Result<List<Ticket>>> ticketsDisponibles() => _repository.mesTicketsDisponibles();
  Future<Result<List<Ticket>>> historiqueComplet() => _repository.tousMesTickets();

  Future<Result<CodeQR?>> codeQRActif() => _repository.codeQRActif();

  Future<Result<CodeQR>> genererCodeQR() => _repository.genererCodeQR();
}
