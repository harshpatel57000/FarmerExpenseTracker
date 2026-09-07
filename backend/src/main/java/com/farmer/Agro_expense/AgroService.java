package com.farmer.Agro_expense;

import java.util.List;

import org.springframework.stereotype.Service;

import com.farmer.Agro_expense.enumValue.ValueUnit;
import com.farmer.exception.ErrorException;

import lombok.RequiredArgsConstructor;


@Service
@RequiredArgsConstructor
public class AgroService {

private final AgroRepository agroRepository;
 
//POST
    public AgroDTO addAgro(AgroDTO dto) {

        Agro agro = AgroMapper.toEntity(dto);

        double totalWeight =agro.getQuantity().getValue()* agro.getMeasurement().getValue();

        agro.setTotalWeight(ValueUnit
                        .builder()
                        .value(totalWeight)
                        .unit(agro.getMeasurement().getUnit())
                        .build());

        Float totalAmount =(float) (agro.getQuantity().getValue()* agro.getPricePerUnit());

        agro.setTotalAmount(totalAmount);

        Agro savedAgro = agroRepository.save(agro);

        return AgroMapper.toDTO(savedAgro);
    }
// GET ALL
    public List<AgroDTO> getAllAgro() {

        List<Agro> agroList = agroRepository.findAll();

        return agroList.stream().map(AgroMapper::toDTO).toList();
   }

   //GET BY ID
   public AgroDTO getAgroById(long id){
        Agro agro=agroRepository.findById(id).orElseThrow(() ->new ErrorException("Agro excepense not found!"));
        return AgroMapper.toDTO(agro);
   }

   //PUT
   public AgroDTO putAgro(Long id,AgroDTO dto){

        Agro agro=agroRepository.findById(id).orElseThrow(() -> new ErrorException("Agro expense not Found id :"+id)); 
        
        ValueUnit vu=ValueUnit.builder().value(dto.getQuantity().getValue()).unit(dto.getQuantity().getUnit()).build();
        ValueUnit mu=ValueUnit.builder().value(dto.getMeasurement().getValue()).unit(dto.getMeasurement().getUnit()).build();
        agro.setProductName(dto.getProductName());
        agro.setPricePerUnit(dto.getPricePerUnit());
        agro.setQuantity(vu);
        agro.setMeasurement(mu);
        agro.setTotalAmount((float) (dto.getQuantity().getValue()* dto.getPricePerUnit()));
        agro.setTotalWeight(ValueUnit.builder().value(dto.getQuantity().getValue()* dto.getMeasurement().getValue()).unit(dto.getMeasurement().getUnit()).build());
        agro.setPurchaseDate(dto.getPurchaseDate());
        Agro updatedAgro = agroRepository.save(agro);
        return AgroMapper.toDTO(updatedAgro);
   }

   //PATCH
   public AgroDTO patchAgro(Long id,AgroDTO dto){
        Agro agro=agroRepository.findById(id).orElseThrow(() ->new ErrorException("Agro not found id :"+id));
        if(dto.getProductName() != null){
                agro.setProductName(dto.getProductName());
        }
        if(dto.getPricePerUnit() != null){
                agro.setPricePerUnit(dto.getPricePerUnit());
        }
        if(dto.getQuantity() != null){
                ValueUnit vu=ValueUnit.builder().value(dto.getQuantity().getValue()).unit(dto.getQuantity().getUnit()).build();
                agro.setQuantity(vu);
        } 
        if(dto.getMeasurement() != null){
                ValueUnit mu=ValueUnit.builder().value(dto.getMeasurement().getValue()).unit(dto.getMeasurement().getUnit()).build();
                agro.setMeasurement(mu);
        }               
        if(dto.getPurchaseDate() != null){
                agro.setPurchaseDate(dto.getPurchaseDate());
        }       
        if(dto.getTotalAmount() != null){
                agro.setTotalAmount(dto.getTotalAmount());
        }
        if(dto.getTotalWeight() != null){
                ValueUnit tw=ValueUnit.builder().value(dto.getTotalWeight().getValue()).unit(dto.getTotalWeight().getUnit()).build();
                agro.setTotalWeight(tw);
        }       
        Agro updatedAgro = agroRepository.save(agro);
        return AgroMapper.toDTO(updatedAgro);
}
//DELETE
   public void deleteAgro(Long id){
        agroRepository.deleteById(id);
   }
}
