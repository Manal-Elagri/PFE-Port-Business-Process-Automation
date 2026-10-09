package Projet_Stage.PFE.entities;


import jakarta.persistence.*;

@Entity
public class OperationEngin {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne private Operation operation;
    @ManyToOne private Engin engin;

    public OperationEngin() {
    }

    public OperationEngin(Long id, Operation operation, Engin engin) {
        this.id = id;
        this.operation = operation;
        this.engin = engin;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Operation getOperation() {
        return operation;
    }

    public void setOperation(Operation operation) {
        this.operation = operation;
    }

    public Engin getEngin() {
        return engin;
    }

    public void setEngin(Engin engin) {
        this.engin = engin;
    }
}
