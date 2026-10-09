package Projet_Stage.PFE.service;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
public class ArretScheduler {

    private final OperationService operationService;

    public ArretScheduler(
            OperationService operationService
    ) {
        this.operationService = operationService;
    }

    @Scheduled(fixedDelay = 60000)
    public void checkOperations() {

        operationService.detectArretAuto();

    }
}
