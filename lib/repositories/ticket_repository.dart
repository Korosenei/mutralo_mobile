import '../core/utils/result.dart';
import '../models/ticket.dart';

abstract interface class ITicketRepository {
  Future<Result<List<Ticket>>> mesTicketsDisponibles();
  Future<Result<List<Ticket>>> tousMesTickets();
  Future<Result<CodeQR?>> codeQRActif();
  Future<Result<CodeQR>> genererCodeQR();
  Future<Result<void>> invaliderCodeQR(int id);
}
