package com.farmer.Agro_expense;


import com.farmer.Agro_expense.enumValue.ValueUnit;

public class AgroMapper {

    public static Agro toEntity(AgroDTO dto) {

        return Agro.builder()
            .productName(dto.getProductName())
            .quantity(toEntity(dto.getQuantity()))
            .measurement(toEntity(dto.getMeasurement()))
            .pricePerUnit(dto.getPricePerUnit())
            .totalWeight(toEntity(dto.getTotalWeight()))
            .totalAmount(dto.getTotalAmount())
            .purchaseDate(dto.getPurchaseDate())
            .build();
    }

    public static ValueUnit toEntity(ValueUnitDTO dto) {

        if (dto == null) {
            return null;
        }

        return ValueUnit.builder()
            .value(dto.getValue())
            .unit(dto.getUnit())
            .build();
    }

    public static AgroDTO toDTO(Agro entity) {

        return AgroDTO.builder()
            .productName(entity.getProductName())
            .quantity(toDTO(entity.getQuantity()))
            .measurement(toDTO(entity.getMeasurement()))
            .pricePerUnit(entity.getPricePerUnit())
            .totalWeight(toDTO(entity.getTotalWeight()))
            .totalAmount(entity.getTotalAmount())
            .purchaseDate(entity.getPurchaseDate())
            .build();
    }

    public static ValueUnitDTO toDTO(ValueUnit entity) {

        if (entity == null) {
            return null;
        }

        return ValueUnitDTO.builder()
            .value(entity.getValue())
            .unit(entity.getUnit())
            .build();
    }
}