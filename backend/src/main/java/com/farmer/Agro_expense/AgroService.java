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

    public AgroDTO addAgro(AgroDTO dto) {

        Agro agro = AgroMapper.toEntity(dto);

        double totalWeight =
                agro.getQuantity().getValue()
                * agro.getMeasurement().getValue();

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

    public List<AgroDTO> getAllAgro() {

        List<Agro> agroList = agroRepository.findAll();

        return agroList.stream()
            .map(AgroMapper::toDTO)
            .toList();
   }
   public AgroDTO getAgroById(long id){
        Agro agro=agroRepository.findById(id).orElseThrow(() ->new ErrorException("Agro excepense not found!"));
        return AgroMapper.toDTO(agro);
   }

}
