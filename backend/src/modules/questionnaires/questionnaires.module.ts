import { Module } from '@nestjs/common';
import { QuestionnaireService } from '../../services/questionnaire.service';
import { MobileQuestionnaireController } from '../../controllers/mobile-questionnaire.controller';

@Module({
  controllers: [MobileQuestionnaireController],
  providers: [QuestionnaireService],
  exports: [QuestionnaireService],
})
export class QuestionnairesModule {}
